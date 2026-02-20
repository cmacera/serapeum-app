import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serapeum_app/core/auth/splash_service.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Initialize authentication
  await SplashService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Serapeum App',
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const Scaffold(
        body: Center(child: Text('Serapeum App Initialized')),
      ),
    );
  }
}
