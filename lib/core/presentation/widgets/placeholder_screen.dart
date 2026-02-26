import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/layout_constants.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;

  /// Optional widget displayed below the placeholder title.
  final Widget? child;

  const PlaceholderScreen({super.key, required this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.paddingOf(context).bottom +
              LayoutConstants.navBarClearance,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontSize: LayoutConstants.placeholderFontSize,
              ),
            ),
            if (child != null) ...[const SizedBox(height: 24), child!],
          ],
        ),
      ),
    );
  }
}
