#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Iniciando proxy local do historico..."
dart run server/proxy.dart &
PROXY_PID=$!
trap 'kill $PROXY_PID 2>/dev/null || true' EXIT
sleep 2

echo "Iniciando Flutter Web..."
flutter pub get
flutter run -d chrome
