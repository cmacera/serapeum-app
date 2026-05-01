import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serapeum_app/core/auth/splash_service.dart';
import 'package:serapeum_app/core/auth/presentation/screens/splash_screen.dart';
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
      final binding = SentryWidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: binding);
      Env.validate();

      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      const sentryDsn = String.fromEnvironment('SENTRY_DSN');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw StateError(
          'SUPABASE_URL and SUPABASE_ANON_KEY must be defined via --dart-define and cannot be empty.',
        );
      }

      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

      const appProviderScope = ProviderScope(child: MyApp());

      if (sentryDsn.isNotEmpty) {
        await SentryFlutter.init((options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
        }, appRunner: () => runApp(appProviderScope));
      } else {
        runApp(appProviderScope);
      }
    },
    (error, stackTrace) {
      Sentry.captureException(error, stackTrace: stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
  );
}

// Clearance for macOS traffic light buttons (close/minimize/fullscreen) which
// overlap Flutter content when titlebarAppearsTransparent + fullSizeContentView
// are set in MainFlutterWindow.swift.
const double _kMacOsTitlebarInset = 28.0;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSuccess = ref.watch(authInitSuccessProvider);
    final router = ref.watch(appRouterProvider);
    final languageCode = ref.watch(localeProvider);

    final theme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ),
      fontFamily: UiConstants.fontFamily,
    );

    Widget Function(BuildContext, Widget?)? macOsBuilder;
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      macOsBuilder = (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(
              top: mq.padding.top + _kMacOsTitlebarInset,
            ),
          ),
          child: child!,
        );
      };
    }

    // null = auth in progress, show splash
    if (authSuccess == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const SplashScreen(),
      );
    }

    // false = auth failed, show retry screen
    if (!authSuccess) {
      return MaterialApp(
        title: UiConstants.appTitle,
        locale: Locale(languageCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme,
        builder: macOsBuilder,
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
      builder: macOsBuilder,
      routerConfig: router,
    );
  }
}
