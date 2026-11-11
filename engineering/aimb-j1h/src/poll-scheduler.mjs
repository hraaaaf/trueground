// J1-H 60-second bounded fallback design fixture. Pure simulation; no network, DB, or Windows writes.
export const FALLBACK_MS = 60_000;
export const RETRY_BASE_MS = 5_000;
export const MAX_RETRY_MS = 60_000;
export const COALESCE_MS = 250;
export const CHANNELS = Object.freeze(['commands', 'files', 'maintenance', 'workspace', 'projects']);
export class PollScheduler {
  #due = 0; #retryCount = 0; #busy = false; #woken = false; #lastNow = 0; #dueCause='startup'; #lastCause=null;
  constructor({fallbackMs=FALLBACK_MS, minTtlMs=80_000}={}) {
    if (!Number.isInteger(fallbackMs)||fallbackMs<1_000||fallbackMs>300_000) throw Error('invalid_fallback');
    if (!Number.isInteger(minTtlMs)||minTtlMs<80_000||minTtlMs<fallbackMs+15_000) throw Error('ttl_margin_insufficient');
    this.fallbackMs=fallbackMs; this.minTtlMs=minTtlMs;
  }
  monotone(now) {if(!Number.isSafeInteger(now)||now<0||now<this.#lastNow) throw Error('invalid_monotonic_clock');this.#lastNow=now;}
  wake(now) {this.monotone(now);this.#woken=true;if (!this.#busy && now+COALESCE_MS<this.#due){this.#due=now+COALESCE_MS;this.#dueCause='wakeup';}}
  step(now) {this.monotone(now);if(this.#busy||now<this.#due)return false;this.#busy=true;this.#lastCause=this.#dueCause;this.#woken=false;return true;}
  complete(now, {ok,partialFailure=false}={}) {
    this.monotone(now); if(!this.#busy)throw Error('no_active_poll');this.#busy=false;
    if(ok && !partialFailure){this.#retryCount=0;this.#due=now+this.fallbackMs;this.#dueCause='fallback';}
    else {this.#retryCount=Math.min(this.#retryCount+1,7);this.#due=now+Math.min(MAX_RETRY_MS, RETRY_BASE_MS*2**(this.#retryCount-1));this.#dueCause='retry';}
    if(this.#woken){this.#woken=false;if(now+COALESCE_MS<this.#due){this.#due=now+COALESCE_MS;this.#dueCause='wakeup';}}
  }
  state(){return Object.freeze({due:this.#due,dueCause:this.#dueCause,lastCause:this.#lastCause,retries:this.#retryCount,busy:this.#busy,woken:this.#woken,channels:[...CHANNELS]});}
}
export function idleProjection({seconds=86_400,legacyA=3,legacyB=2,legacyAInterval=4,legacyBInterval=8,groupInterval=60}={}){
  const legacy=legacyA*(seconds/legacyAInterval)+legacyB*(seconds/legacyBInterval);
  const grouped=Math.ceil(seconds/groupInterval);
  return {legacyNonceInserts:legacy,groupedNonceInserts:grouped,reduction:(1-grouped/legacy),disclaimer:'Counts nonce inserts at idle only; deletes, indexes, audits, results, DO operations excluded'};
}
