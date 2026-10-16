import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_logo.dart';
import 'auth_promo_panel.dart';

/// Адаптивний каркас для екранів авторизації.
///
/// Широкий екран (≥ 900 px): промо-панель ліворуч + форма праворуч.
/// Вузький екран: лише логотип і форма по центру.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});

  /// Картка з формою (вхід, реєстрація або відновлення пароля).
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= AppBreakpoints.medium;
          final padding = isWide ? AppSpacing.xl : AppSpacing.m;

          final form = Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isWide) ...[
                      const AppLogo(),
                      const SizedBox(height: AppSpacing.l),
                    ],
                    child,
                  ],
                ),
              ),
            ),
          );

          if (!isWide) {
            return SafeArea(child: form);
          }

          final panelWidth =
              constraints.maxWidth >= AppBreakpoints.expanded ? 500.0 : 400.0;

          return Row(
            children: [
              SizedBox(width: panelWidth, child: const AuthPromoPanel()),
              Expanded(child: form),
            ],
          );
        },
      ),
    );
  }
}
