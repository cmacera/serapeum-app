import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';

import '../../../../core/presentation/widgets/placeholder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(title: UiConstants.controlCenterTitle);
  }
}
