import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/layout_constants.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.paddingOf(context).bottom +
                LayoutConstants.navBarClearance,
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.subtitle,
              fontSize: LayoutConstants.placeholderFontSize,
            ),
          ),
        ),
      ),
    );
  }
}
