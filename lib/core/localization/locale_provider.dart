import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'locale_provider.g.dart';

@riverpod
String locale(Ref ref) {
  // Save the previous handler to restore it later
  final oldHandler = PlatformDispatcher.instance.onLocaleChanged;

  // Subscribe to locale changes to refresh the provider automatically
  PlatformDispatcher.instance.onLocaleChanged = () {
    ref.invalidateSelf();
    // Also call the original handler if it existed
    oldHandler?.call();
  };

  // Ensure we clean up by restoring the previous handler
  ref.onDispose(() {
    if (PlatformDispatcher.instance.onLocaleChanged != null) {
      PlatformDispatcher.instance.onLocaleChanged = oldHandler;
    }
  });

  // Returns the primary language code (e.g., 'en', 'es')
  return PlatformDispatcher.instance.locale.languageCode;
}
