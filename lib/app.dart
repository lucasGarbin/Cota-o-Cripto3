import 'package:flutter/material.dart';

import 'controllers/market_controller.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_shell.dart';

class CotacaoCripto3App extends StatefulWidget {
  const CotacaoCripto3App({super.key});

  @override
  State<CotacaoCripto3App> createState() => _CotacaoCripto3AppState();
}

class _CotacaoCripto3AppState extends State<CotacaoCripto3App> {
  final MarketController _controller = MarketController();
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _controller.initialize();
  }

  @override
  void dispose() {
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
      home: HomeShell(
        controller: _controller,
        darkModeEnabled: _themeMode == ThemeMode.dark,
        onThemeChanged: _setDarkMode,
      ),
    );
  }
}
