import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/discovery_provider.dart';

class DiscoverInputBar extends ConsumerWidget {
  final bool isSearching;
  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  const DiscoverInputBar({
    super.key,
    required this.isSearching,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // bottom: false because we apply the bottom inset manually via
    // MediaQuery.padding.bottom so the AnimatedContainer can animate
    // its width without the SafeArea interfering with the layout bounds.
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: isSearching ? 0.0 : 16.0,
          right: isSearching ? 0.0 : 16.0,
          top: 16.0,
          bottom: 16.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final expandedWidth = constraints.maxWidth;
            return Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: isSearching ? 54.0 : expandedWidth,
                decoration: BoxDecoration(
                  color: isSearching
                      ? Colors.transparent
                      : AppColors.inputSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(32.0),
                  border: Border.all(
                    color: isSearching
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ClipRect(
                        child: IgnorePointer(
                          ignoring: isSearching,
                          child: AnimatedOpacity(
                            opacity: isSearching ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 12.0,
                                right: 4.0,
                              ),
                              child: TextField(
                                controller: controller,
                                enabled: !isSearching,
                                textInputAction: TextInputAction.send,
                                onSubmitted: onSearch,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.askOracleHint,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildActionButton(ref, l10n),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(WidgetRef ref, AppLocalizations l10n) {
    return Semantics(
      label: isSearching ? l10n.cancel : l10n.askOracleTooltip,
      button: true,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isSearching
              ? []
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Material(
          color: isSearching ? Colors.grey.shade800 : AppColors.accent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isSearching
                ? () {
                    HapticFeedback.selectionClick();
                    ref.read(discoveryProvider.notifier).cancelSearch();
                  }
                : () {
                    HapticFeedback.selectionClick();
                    onSearch(controller.text);
                  },
            child: Center(
              child: isSearching
                  ? const Icon(Icons.close, color: Colors.white, size: 20)
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
