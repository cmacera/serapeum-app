import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/failure.dart';
import '../../domain/entities/orchestrator_response.dart';
import 'discover_history_provider.dart';
import 'discover_query_provider.dart';

enum DiscoverState { initial, searching, result }

class DiscoveryStateData {
  final DiscoverState state;
  final String? currentQuery;
  final int elapsedSeconds;

  DiscoveryStateData({
    this.state = DiscoverState.initial,
    this.currentQuery,
    this.elapsedSeconds = 0,
  });

  DiscoveryStateData copyWith({
    DiscoverState? state,
    Object? currentQuery = _unset,
    int? elapsedSeconds,
  }) {
    return DiscoveryStateData(
      state: state ?? this.state,
      currentQuery: currentQuery == _unset
          ? this.currentQuery
          : currentQuery as String?,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }

  static const _unset = Object();
}

class DiscoveryNotifier extends StateNotifier<DiscoveryStateData> {
  final Ref _ref;
  Timer? _timer;

  DiscoveryNotifier(this._ref) : super(DiscoveryStateData());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(elapsedSeconds: 0);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: timer.tick);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void startNewConversation() {
    _stopTimer();
    state = DiscoveryStateData(state: DiscoverState.initial);
  }

  Future<OrchestratorResponse?> executeSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return null;
    }

    if (state.state == DiscoverState.searching) {
      return null;
    }

    // 1. Enter searching state (stay on initial screen UX)
    _startTimer();
    state = state.copyWith(
      state: DiscoverState.searching,
      currentQuery: trimmedQuery,
    );

    try {
      // 2. Coordinate the request
      // Note: we use read here because we want to trigger the future once
      final response = await _ref.read(
        discoverQueryProvider(trimmedQuery).future,
      );

      _stopTimer();

      if (response == null) {
        state = state.copyWith(state: DiscoverState.initial);
        return null;
      }

      // 3. Handle response states
      if (response is OrchestratorGeneral ||
          response is OrchestratorSelection) {
        // Happy path: Save to history and show results
        _ref.read(discoverHistoryProvider.notifier).addQuery(trimmedQuery);
        state = state.copyWith(state: DiscoverState.result);
      } else {
        // Refusal or Error: stay in initial, showing alert is handled by UI
        // We revert to initial state so the input bar and sentences are reset/handled
        state = state.copyWith(state: DiscoverState.initial);
      }
      return response;
    } catch (e) {
      _stopTimer();
      // On error, we always reset to initial so the user can try again
      state = state.copyWith(state: DiscoverState.initial);
      if (e is ServerFailure) {
        return OrchestratorError(
          error: 'SERVER_ERROR',
          details: e.statusCode.toString(),
        );
      } else if (e is NetworkFailure) {
        return const OrchestratorError(error: 'NETWORK_ERROR');
      } else if (e is TimeoutFailure) {
        return const OrchestratorError(error: 'TIMEOUT_ERROR');
      }
      return OrchestratorError(error: 'UNKNOWN_ERROR', details: e.toString());
    }
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryStateData>((ref) {
      return DiscoveryNotifier(ref);
    });
