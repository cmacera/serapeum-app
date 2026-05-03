import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/core/auth/providers/auth_init_provider.dart';
import 'package:serapeum_app/core/auth/splash_service.dart';
import 'package:serapeum_app/core/constants/app_colors.dart';
import 'package:serapeum_app/core/constants/ui_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _runAuth();
  }

  Future<void> _runAuth() async {
    try {
      final success = await SplashService.initialize();
      if (mounted) {
        ref.read(authInitSuccessProvider.notifier).state = success;
      }
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(UiConstants.splashImagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
