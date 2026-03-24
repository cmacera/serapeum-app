import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the result of the [SplashService.initialize] call.
/// Overridden in [main] with the actual initialization result.
final authInitSuccessProvider = StateProvider<bool>((ref) => true);
