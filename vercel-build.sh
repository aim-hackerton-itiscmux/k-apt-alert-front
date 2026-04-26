#!/usr/bin/env bash
# Vercel build script for Flutter web.
# - Downloads a pinned Flutter SDK tarball (faster than git clone + precache).
# - Builds the web release with API_BASE_URL injected via --dart-define.
#
# Required env vars on Vercel:
#   (none required — API_BASE_URL is optional, defaults to live Supabase URL)
# Optional env vars:
#   API_BASE_URL  Override the API base URL at build time.
set -euo pipefail

# If GitHub Actions (or another CI) already produced build/web, skip the
# Flutter download + rebuild and just let Vercel package the prebuilt output.
if [ -f "build/web/index.html" ]; then
  echo "==> build/web/index.html exists — skipping Flutter build (prebuilt by CI)."
  exit 0
fi

FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.7}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
FLUTTER_TAR_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  echo "==> Downloading Flutter $FLUTTER_VERSION..."
  TMP_TAR="$(mktemp -t flutter-XXXXXX.tar.xz)"
  curl -fSL --retry 3 "$FLUTTER_TAR_URL" -o "$TMP_TAR"
  mkdir -p "$(dirname "$FLUTTER_HOME")"
  tar -xJf "$TMP_TAR" -C "$(dirname "$FLUTTER_HOME")"
  rm -f "$TMP_TAR"
fi

# Vercel runs builds as root; git refuses to operate on Flutter's repo
# unless the path is whitelisted as a safe directory.
git config --global --add safe.directory "$FLUTTER_HOME" || true
git config --global --add safe.directory '*' || true

export PATH="$FLUTTER_HOME/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get

API_BASE_URL_VALUE="${API_BASE_URL:-https://xnyhzyvigazofjoozuub.supabase.co/functions/v1}"
SUPABASE_URL_VALUE="${SUPABASE_URL:-https://xnyhzyvigazofjoozuub.supabase.co}"
SUPABASE_ANON_KEY_VALUE="${SUPABASE_ANON_KEY:-}"
AUTH_REDIRECT_URL_VALUE="${AUTH_REDIRECT_URL:-}"

echo "==> Building web release"
echo "    API_BASE_URL=$API_BASE_URL_VALUE"
echo "    SUPABASE_URL=$SUPABASE_URL_VALUE"
echo "    SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY_VALUE:+[set]}${SUPABASE_ANON_KEY_VALUE:-[not set — Auth disabled]}"
echo "    AUTH_REDIRECT_URL=${AUTH_REDIRECT_URL_VALUE:-[default site url]}"

flutter build web \
  --release \
  --dart-define=API_BASE_URL="$API_BASE_URL_VALUE" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL_VALUE" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY_VALUE" \
  --dart-define=AUTH_REDIRECT_URL="$AUTH_REDIRECT_URL_VALUE"

echo "==> Build complete: build/web"
