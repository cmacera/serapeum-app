import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serapeum_app/core/auth/splash_service.dart';
import 'core/auth/presentation/screens/auth_error_screen.dart';
import 'core/auth/providers/auth_init_provider.dart';
import 'core/env/env.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/ui_constants.dart';
import 'core/localization/locale_provider.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Env.validate();

      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      const sentryDsn = String.fromEnvironment('SENTRY_DSN');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw StateError(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined via --dart-define and cannot be empty.',
        );
      }

      // Initialize Supabase
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      // Initialize authentication
      final authSuccess = await SplashService.initialize();

      final appProviderScope = ProviderScope(
        overrides: [authInitSuccessProvider.overrideWith((ref) => authSuccess)],
        child: const MyApp(),
      );

      if (sentryDsn.isNotEmpty) {
        await SentryFlutter.init((options) {
          options.dsn = sentryDsn;
          // Capture 100% of transactions in debug; use a lower rate in release
          options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
        }, appRunner: () => runApp(appProviderScope));
      } else {
        runApp(appProviderScope);
      }
    },
    (error, stackTrace) {
      // Fire-and-forget: don't await so the handler stays synchronous
      Sentry.captureException(error, stackTrace: stackTrace);
      // Rethrow preserving original stack trace so runZonedGuarded sees it
      Error.throwWithStackTrace(error, stackTrace);
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSuccess = ref.watch(authInitSuccessProvider);
    final router = ref.watch(appRouterProvider);
    final languageCode = ref.watch(localeProvider);

    final theme = ThemeData(
      brightness: Brightness.dark,
      // Match Stitch customColor
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ),
      fontFamily: UiConstants.fontFamily, // The font from the Stitch project
    );

    if (!authSuccess) {
      return MaterialApp(
        title: UiConstants.appTitle,
        locale: Locale(languageCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        home: AuthErrorScreen(
          onRetry: () async {
            final success = await SplashService.initialize();
            if (success) {
              ref.read(authInitSuccessProvider.notifier).state = true;
            }
          },
        ),
      );
    }

    return MaterialApp.router(
      title: UiConstants.appTitle,
      locale: Locale(languageCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
      routerConfig: router,
    );
  }
}
