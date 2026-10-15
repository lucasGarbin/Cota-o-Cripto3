@echo off
setlocal
cd /d "%~dp0"
call prepare_mobile_windows.bat
if errorlevel 1 exit /b 1

echo.
echo ==========================================
echo Dispositivos Flutter encontrados

echo ==========================================
flutter devices

echo.
echo O Flutter abrira a selecao de dispositivo se houver mais de um.
echo Selecione seu celular Android.
flutter run
if errorlevel 1 goto :error
exit /b 0

:error
echo.
echo Falha ao iniciar no celular.
echo Confira Depuracao USB, autorizacao RSA e Android SDK.
pause
exit /b 1
