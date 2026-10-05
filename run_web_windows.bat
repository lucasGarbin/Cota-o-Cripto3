@echo off
setlocal
cd /d "%~dp0"

echo Iniciando proxy local do historico...
start "Cotacao Cripto3 - Proxy" cmd /k "dart run server\proxy.dart"

timeout /t 2 /nobreak >nul

echo Iniciando Flutter Web...
flutter pub get
flutter run -d chrome
