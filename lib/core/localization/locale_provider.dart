import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@riverpod
String locale(LocaleRef ref) {
  // Returns the primary language code (e.g., 'en', 'es')
  return PlatformDispatcher.instance.locale.languageCode;
}
