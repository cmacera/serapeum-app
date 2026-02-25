import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

/// Returns the device's primary language code (e.g. 'en', 'es').
/// Re-evaluates automatically when the system locale changes.
@riverpod
String locale(Ref ref) {
  // Save the previous handler to restore it later
  final oldHandler = PlatformDispatcher.instance.onLocaleChanged;

  // Subscribe to locale changes to refresh the provider automatically
  PlatformDispatcher.instance.onLocaleChanged = () {
    ref.invalidateSelf();
    oldHandler?.call();
  };

  ref.onDispose(() {
    if (PlatformDispatcher.instance.onLocaleChanged != null) {
      PlatformDispatcher.instance.onLocaleChanged = oldHandler;
    }
  });

  // Returns the primary language code (e.g., 'en', 'es')
  return PlatformDispatcher.instance.locale.languageCode;
}
