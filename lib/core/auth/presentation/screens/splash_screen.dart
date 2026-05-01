import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/auth/providers/auth_init_provider.dart';
import 'package:serapeum_app/core/auth/splash_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start auth immediately, dismiss native splash after first Flutter frame.
    _runAuth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
  }

  Future<void> _runAuth() async {
    final success = await SplashService.initialize();
    if (mounted) {
      ref.read(authInitSuccessProvider.notifier).state = success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0C0A14),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splash1.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
