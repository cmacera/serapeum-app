import 'package:flutter_riverpod/flutter_riverpod.dart';

/// null = loading (splash shown), true = success, false = auth failed.
final authInitSuccessProvider = StateProvider<bool?>((ref) => null);
