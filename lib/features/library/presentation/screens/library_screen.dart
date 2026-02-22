import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';

import '../../../../core/presentation/widgets/placeholder_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: UiConstants.myLibraryTitle);
  }
}
