import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'locale_provider.g.dart';

@riverpod
String locale(Ref ref) {
  // Subscribe to locale changes to refresh the provider automatically
  PlatformDispatcher.instance.onLocaleChanged = () {
    ref.invalidateSelf();
  };

  // Returns the primary language code (e.g., 'en', 'es')
  return PlatformDispatcher.instance.locale.languageCode;
}
