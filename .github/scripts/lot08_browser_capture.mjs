import { spawn } from 'node:child_process';
import { mkdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const [chromeBin, baseUrl, widthRaw, heightRaw, outputDir] = process.argv.slice(2);
if (!chromeBin || !baseUrl || !widthRaw || !heightRaw || !outputDir) {
  throw new Error(
    'Usage: node lot08_browser_capture.mjs <chrome> <baseUrl> <width> <height> <outputDir>',
  );
}

const width = Number(widthRaw);
const height = Number(heightRaw);
const profileDir = join(
  tmpdir(),
  `trueground-lot08-chrome-${process.pid}-${width}`,
);
await mkdir(profileDir, { recursive: true });
await mkdir(outputDir, { recursive: true });

const chrome = spawn(
  chromeBin,
  [
    '--headless',
    '--disable-gpu',
    '--no-sandbox',
    '--hide-scrollbars',
    '--remote-debugging-port=0',
    `--user-data-dir=${profileDir}`,
    `--window-size=${width},${height}`,
    '--force-device-scale-factor=1',
    '--run-all-compositor-stages-before-draw',
    `${baseUrl}/#/values`,
  ],
  { stdio: ['ignore', 'ignore', 'pipe'] },
);

let browserWs;
let stderr = '';
const devtoolsReady = new Promise((resolve, reject) => {
  const timeout = setTimeout(
    () => reject(new Error(`Chrome DevTools did not start. ${stderr}`)),
    15000,
  );
  chrome.stderr.setEncoding('utf8');
  chrome.stderr.on('data', (chunk) => {
    stderr += chunk;
    const match = stderr.match(/DevTools listening on (ws:\/\/[^\s]+)/);
    if (match && !browserWs) {
      browserWs = match[1];
      clearTimeout(timeout);
      resolve();
    }
  });
  chrome.on('exit', (code) => {
    if (!browserWs) {
      clearTimeout(timeout);
      reject(
        new Error(
          `Chrome exited before DevTools was ready (code ${code}). ${stderr}`,
        ),
      );
    }
  });
});

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function getPageWebSocket() {
  await devtoolsReady;
  const parsed = new URL(browserWs);
  const endpoint = `http://${parsed.hostname}:${parsed.port}/json/list`;
  for (let attempt = 0; attempt < 50; attempt += 1) {
    const response = await fetch(endpoint);
    if (response.ok) {
      const targets = await response.json();
      const page = targets.find((target) => target.type === 'page');
      if (page?.webSocketDebuggerUrl) return page.webSocketDebuggerUrl;
    }
    await sleep(200);
  }
  throw new Error('No page target exposed by Chrome DevTools.');
}

let socket;
let nextId = 1;
const pending = new Map();

function command(method, params = {}) {
  return new Promise((resolve, reject) => {
    const id = nextId++;
    pending.set(id, { resolve, reject, method });
    socket.send(JSON.stringify({ id, method, params }));
  });
}

async function evaluate(expression) {
  const response = await command('Runtime.evaluate', {
    expression,
    returnByValue: true,
    awaitPromise: true,
  });
  if (response.exceptionDetails) {
    throw new Error(
      `Runtime.evaluate failed: ${JSON.stringify(response.exceptionDetails)}`,
    );
  }
  return response.result?.value;
}

async function waitForLabel(label, timeoutMs = 10000) {
  const started = Date.now();
  while (Date.now() - started < timeoutMs) {
    const found = await evaluate(`(() => {
      const labels = [...document.querySelectorAll('[aria-label]')]
        .map((el) => el.getAttribute('aria-label'))
        .filter(Boolean);
      return labels.some(
        (value) =>
          value === ${JSON.stringify(label)} ||
          value.includes(${JSON.stringify(label)}),
      );
    })()`);
    if (found) return;
    await sleep(200);
  }
  const labels = await evaluate(
    "[...document.querySelectorAll('[aria-label]')]" +
      ".map((el) => el.getAttribute('aria-label'))" +
      '.filter(Boolean).slice(0, 80)',
  );
  throw new Error(
    `Timed out waiting for aria-label ${label}. Labels: ${JSON.stringify(labels)}`,
  );
}

async function enableSemantics() {
  for (let attempt = 0; attempt < 30; attempt += 1) {
    const enabled = await evaluate(`(() => {
      const placeholder = document.querySelector('flt-semantics-placeholder');
      if (placeholder) placeholder.click();
      return document.querySelectorAll('[aria-label]').length > 0;
    })()`);
    if (enabled) return;
    await sleep(200);
  }
  throw new Error('Flutter web semantics did not expose aria-label nodes.');
}

async function labelRect(label) {
  return evaluate(`(() => {
    const items = [...document.querySelectorAll('[aria-label]')];
    const exact = items.find(
      (el) => el.getAttribute('aria-label') === ${JSON.stringify(label)},
    );
    const partial = items.find((el) =>
      (el.getAttribute('aria-label') || '').includes(${JSON.stringify(label)}),
    );
    const el = exact || partial;
    if (!el) return null;
    const rect = el.getBoundingClientRect();
    return {
      label: el.getAttribute('aria-label'),
      x: rect.left + rect.width / 2,
      y: rect.top + rect.height / 2,
    };
  })()`);
}

async function clickLabel(label) {
  await waitForLabel(label);
  for (let attempt = 0; attempt < 30; attempt += 1) {
    const rect = await labelRect(label);
    if (!rect) throw new Error(`Label disappeared before click: ${label}`);
    if (
      rect.y >= 8 &&
      rect.y <= height - 8 &&
      rect.x >= 8 &&
      rect.x <= width - 8
    ) {
      await command('Input.dispatchMouseEvent', {
        type: 'mouseMoved',
        x: rect.x,
        y: rect.y,
      });
      await command('Input.dispatchMouseEvent', {
        type: 'mousePressed',
        x: rect.x,
        y: rect.y,
        button: 'left',
        clickCount: 1,
      });
      await command('Input.dispatchMouseEvent', {
        type: 'mouseReleased',
        x: rect.x,
        y: rect.y,
        button: 'left',
        clickCount: 1,
      });
      await sleep(700);
      return;
    }
    const deltaY =
      rect.y > height
        ? Math.max(300, Math.min(700, rect.y - height / 2))
        : -500;
    await command('Input.dispatchMouseEvent', {
      type: 'mouseWheel',
      x: width / 2,
      y: height / 2,
      deltaX: 0,
      deltaY,
    });
    await sleep(250);
  }
  throw new Error(`Could not bring ${label} into the viewport.`);
}

async function capture(name) {
  await sleep(500);
  const result = await command('Page.captureScreenshot', {
    format: 'png',
    fromSurface: true,
  });
  if (!result.data) throw new Error(`No screenshot data for ${name}`);
  await writeFile(
    join(outputDir, name),
    Buffer.from(result.data, 'base64'),
  );
}

async function navigate(path) {
  await command('Page.navigate', { url: `${baseUrl}${path}` });
  await sleep(1500);
  await enableSemantics();
}

try {
  const pageWs = await getPageWebSocket();
  socket = new WebSocket(pageWs);
  await new Promise((resolve, reject) => {
    socket.addEventListener('open', resolve, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });
  socket.addEventListener('message', (event) => {
    const message = JSON.parse(event.data);
    if (!message.id) return;
    const entry = pending.get(message.id);
    if (!entry) return;
    pending.delete(message.id);
    if (message.error) {
      entry.reject(
        new Error(`${entry.method}: ${JSON.stringify(message.error)}`),
      );
    } else {
      entry.resolve(message.result || {});
    }
  });

  await command('Page.enable');
  await command('Runtime.enable');

  await navigate('/#/values');
  await waitForLabel('Family');
  await capture(`browser_values_${width}_choose.png`);
  await clickLabel('Family');
  await waitForLabel('Take my next step');
  await capture(`browser_values_${width}_action.png`);
  await clickLabel('Take my next step');
  await waitForLabel('Back to Home');
  await capture(`browser_values_${width}_terminal.png`);

  await clickLabel('Support');
  await waitForLabel('Someone I trust');
  await capture(`browser_support_${width}_menu.png`);
  await clickLabel('Someone I trust');
  await waitForLabel('Back to support choices');
  await capture(`browser_support_${width}_trusted.png`);
  await clickLabel('Back to support choices');
  await waitForLabel('My therapist or care team');
  await clickLabel('My therapist or care team');
  await waitForLabel('Back to support choices');
  await capture(`browser_support_${width}_care.png`);
  await clickLabel('Back to support choices');
  await waitForLabel('Find professional support outside TrueGround');
  await clickLabel('Find professional support outside TrueGround');
  await waitForLabel('Back to support choices');
  await capture(`browser_support_${width}_local.png`);
} finally {
  try {
    socket?.close();
  } catch {}
  chrome.kill('SIGTERM');
  await sleep(300);
  await rm(profileDir, { recursive: true, force: true });
}
