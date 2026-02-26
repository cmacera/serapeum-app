import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../providers/discovery_provider.dart';
import '../widgets/discover_result_view.dart';
import '../widgets/discovery_ui_helper.dart';
import '../../../../core/constants/app_colors.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _executeSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    // Execute search and get response
    final response = await ref
        .read(discoveryProvider.notifier)
        .executeSearch(trimmedQuery);

    if (mounted) {
      DiscoveryUIHelper.handleSearchResponse(
        context: context,
        response: response,
        currentState: ref.read(discoveryProvider),
        onClear: () {
          setState(() {
            _textController.clear();
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final discoveryState = ref.watch(discoveryProvider);

    // Listen for state changes to clear the controller when reset
    ref.listen(discoveryProvider, (previous, next) {
      if (next.state == DiscoverState.initial &&
          _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });

    return Column(
      children: [
        Expanded(child: _buildBody(context, l10n, discoveryState)),
        if (discoveryState.state != DiscoverState.result)
          _buildInputBar(
            context,
            l10n,
            discoveryState.state == DiscoverState.searching,
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    DiscoveryStateData discoveryState,
  ) {
    if (discoveryState.state == DiscoverState.result) {
      return DiscoverResultView(query: discoveryState.currentQuery!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (discoveryState.state == DiscoverState.searching)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  l10n.consultingOracle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${discoveryState.elapsedSeconds}s elapsed',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            )
          else
            const Column(
              children: [
                SizedBox(height: 100),
                Opacity(
                  opacity: 0.5,
                  child: Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isSearching,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: 16.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.inputSurface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(32.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: !isSearching,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _executeSearch,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
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
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSearching ? Colors.grey : AppColors.accent,
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
                child: IconButton(
                  icon: isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  onPressed: isSearching
                      ? null
                      : () => _executeSearch(_textController.text),
                  tooltip: l10n.askOracleTooltip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
