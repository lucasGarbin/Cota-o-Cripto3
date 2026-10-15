@echo off
setlocal
cd /d "%~dp0"

echo ==========================================
echo Cotacao Cripto3 - Preparacao Android

echo ==========================================

where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter nao foi encontrado no PATH.
  echo Instale/configure o Flutter antes de continuar.
  pause
  exit /b 1
)

if not exist "android\gradlew.bat" (
  echo Estrutura Android completa nao encontrada.
  echo Gerando arquivos nativos compativeis com seu Flutter...
  flutter create --platforms=android,web .
  if errorlevel 1 goto :error

  echo Restaurando logo, splash e configuracoes Android...
  copy /Y "mobile_branding\android\AndroidManifest.xml" "android\app\src\main\AndroidManifest.xml" >nul
  xcopy /E /I /Y "mobile_branding\android\res" "android\app\src\main\res" >nul
)

flutter pub get
if errorlevel 1 goto :error

echo.
echo Projeto Android preparado.
echo Agora conecte o celular e rode: flutter devices

echo Depois: flutter run -d ID_DO_SEU_CELULAR
exit /b 0

:error
echo.
echo Nao foi possivel preparar o projeto Android.
pause
exit /b 1
