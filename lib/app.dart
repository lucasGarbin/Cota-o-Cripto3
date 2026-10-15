import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/market_controller.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';

class CotacaoCripto3App extends StatefulWidget {
  const CotacaoCripto3App({super.key});

  @override
  State<CotacaoCripto3App> createState() => _CotacaoCripto3AppState();
}

class _CotacaoCripto3AppState extends State<CotacaoCripto3App> {
  final MarketController _controller = MarketController();
  ThemeMode _themeMode = ThemeMode.dark;
  bool _showSplash = true;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();

    // Mantém a inicialização existente do mercado e dos favoritos.
    _controller.initialize();

    // Splash curta apenas para identidade visual. A inicialização da API
    // continua acontecendo em paralelo para não atrasar o aplicativo.
    _splashTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setDarkMode(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotação Cripto3',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOut,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        child: _showSplash
            ? const SplashScreen(key: ValueKey('splash'))
            : HomeShell(
                key: const ValueKey('home'),
                controller: _controller,
                darkModeEnabled: _themeMode == ThemeMode.dark,
                onThemeChanged: _setDarkMode,
              ),
      ),
    );
  }
}
