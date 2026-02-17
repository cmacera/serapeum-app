import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
