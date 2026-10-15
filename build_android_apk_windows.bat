@echo off
setlocal
cd /d "%~dp0"
flutter pub get
if errorlevel 1 exit /b 1
flutter build apk --release
if errorlevel 1 exit /b 1
echo.
echo APK gerado em:
echo build\app\outputs\flutter-apk\app-release.apk
pause
endlocal
