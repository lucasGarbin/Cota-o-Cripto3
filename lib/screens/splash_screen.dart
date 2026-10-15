import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 164,
                  height: 164,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yellow.withOpacity(0.16),
                        blurRadius: 36,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/branding/splash_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                    children: [
                      TextSpan(text: 'Cotação '),
                      TextSpan(
                        text: 'Cripto3',
                        style: TextStyle(color: AppTheme.yellow),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mercado cripto em tempo real',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 42),
                SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: const LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: Color(0xFF17334A),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.yellow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
