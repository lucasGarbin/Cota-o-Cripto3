# Atualizações 2.4 — Logo, Splash e Mobile

Esta atualização preserva as funcionalidades existentes de favoritos, gráficos,
conversão, temas e proxy Web.

## Código Flutter

- `lib/app.dart` — adiciona a etapa de splash sem alterar a inicialização do `MarketController`.
- `lib/screens/splash_screen.dart` — nova tela de splash responsiva.
- `pubspec.yaml` — registra os assets de branding e incrementa a versão.

## Branding

- `assets/branding/app_icon.png`
- `assets/branding/splash_logo.png`

## Android

- `android/app/src/main/AndroidManifest.xml` — registra ícone/roundIcon e mantém INTERNET.
- `android/app/src/main/res/mipmap-*/ic_launcher.png` — ícones por densidade.
- `android/app/src/main/res/drawable-nodpi/splash_logo.png`
- `android/app/src/main/res/drawable-nodpi/splash_icon_android12.png`
- `android/app/src/main/res/drawable*/launch_background.xml`
- `android/app/src/main/res/values/colors.xml`
- `android/app/src/main/res/values*/styles.xml` — splash tradicional e Android 12+.

## Web / PWA

- `web/favicon.png`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`
- `web/index.html`
- `web/manifest.json`

## Scripts Mobile

- `prepare_mobile_windows.bat`
- `run_android_windows.bat`
- `build_android_apk_windows.bat`
- `prepare_mobile_unix.sh`
- `mobile_branding/` — backup dos assets nativos para regeneração segura das plataformas.

## Não foram alterados

A lógica funcional abaixo foi mantida intacta:

- `lib/controllers/market_controller.dart`
- `lib/services/coinbase_service.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/screens/currencies_screen.dart`
- `lib/screens/conversion_screen.dart`
- `server/proxy.dart`
