import 'package:flutter/material.dart';

import '../../../../core/constants/ui_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom +
              UiConstants.navBarClearance,
        ),
        child: Center(
          child: Text(
            UiConstants.controlCenterTitle,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
