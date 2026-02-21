import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'My Library',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
        ),
      ),
    );
  }
}
