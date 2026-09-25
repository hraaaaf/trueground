#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.2"
FLUTTER_DIR="${HOME}/.trueground-flutter"

if [ ! -x "${FLUTTER_DIR}/bin/flutter" ]; then
  rm -rf "${FLUTTER_DIR}"
  git clone --depth 1 --single-branch --branch "${FLUTTER_VERSION}" \
    https://github.com/flutter/flutter.git "${FLUTTER_DIR}"
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"

flutter --version
flutter config --enable-web
flutter precache --web
flutter pub get
flutter build web --release
