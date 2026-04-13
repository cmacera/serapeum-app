import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/discovery_provider.dart';
import '../widgets/discover_input_bar.dart';
import '../widgets/discover_query_overlay.dart';
import '../widgets/discover_result_view.dart';
import '../widgets/discovery_ui_helper.dart';
import '../widgets/oracle_lines_animation.dart';

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

    final notifier = ref.read(discoveryProvider.notifier);
    final response = await notifier.executeSearch(trimmedQuery);

    if (mounted && !notifier.lastSearchWasCancelled) {
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
    final discoveryState = ref.watch(discoveryProvider);
    final isSearching = discoveryState.state == DiscoverState.searching;
    final isResult = discoveryState.state == DiscoverState.result;

    ref.listen(discoveryProvider, (previous, next) {
      if (next.state == DiscoverState.initial &&
          _textController.text.isNotEmpty) {
        _textController.clear();
      }
    });

    return Stack(
      children: [
        // Layer 0: main body (oracle lines or result view)
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isResult
                ? DiscoverResultView(
                    key: const ValueKey('result'),
                    query: discoveryState.currentQuery ?? '',
                  )
                : Padding(
                    key: const ValueKey('oracle'),
                    padding: EdgeInsets.only(
                      bottom: DiscoverInputBar.visualHeight(
                        MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                    child: Center(
                      child: OracleLinesAnimation(isSearching: isSearching),
                    ),
                  ),
          ),
        ),

        // Layer 1: floating query text + elapsed counter
        if (!isResult)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 24,
            right: 24,
            child: DiscoverQueryOverlay(
              query: discoveryState.currentQuery ?? '',
              elapsedSeconds: discoveryState.elapsedSeconds,
              visible: isSearching,
            ),
          ),

        // Layer 2: animated input bar (collapses to spinner during search)
        if (!isResult)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DiscoverInputBar(
              isSearching: isSearching,
              controller: _textController,
              onSearch: _executeSearch,
            ),
          ),
      ],
    );
  }
}
