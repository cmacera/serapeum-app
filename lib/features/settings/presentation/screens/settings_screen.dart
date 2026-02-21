import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Control Center',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
        ),
      ),
    );
  }
}
