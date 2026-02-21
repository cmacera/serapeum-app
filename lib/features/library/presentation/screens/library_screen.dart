import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80.0,
        ),
        child: Center(
          child: Text(
            UiConstants.myLibraryTitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
