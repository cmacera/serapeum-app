import 'package:flutter/material.dart';
import '../../constants/layout_constants.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).padding.bottom +
              LayoutConstants.navBarClearance,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
