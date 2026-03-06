import 'dart:async';
import 'dart:convert';
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
  final OrchestratorResponse? cachedResponse;

  DiscoveryStateData({
    this.state = DiscoverState.initial,
    this.currentQuery,
    this.elapsedSeconds = 0,
    this.cachedResponse,
  });

  DiscoveryStateData copyWith({
    DiscoverState? state,
    Object? currentQuery = _unset,
    int? elapsedSeconds,
    Object? cachedResponse = _unset,
  }) {
    return DiscoveryStateData(
      state: state ?? this.state,
      currentQuery: currentQuery == _unset
          ? this.currentQuery
          : currentQuery as String?,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      cachedResponse: cachedResponse == _unset
          ? this.cachedResponse
          : cachedResponse as OrchestratorResponse?,
    );
  }

  static const _unset = Object();
}

class DiscoveryNotifier extends StateNotifier<DiscoveryStateData> {
  final Ref _ref;
  Timer? _timer;
  int _requestEpoch = 0;

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
    _requestEpoch++;
    state = DiscoveryStateData(state: DiscoverState.initial);
  }

  void loadCachedResult(String query, OrchestratorResponse cachedResponse) {
    _stopTimer();
    _requestEpoch++;
    state = DiscoveryStateData(
      state: DiscoverState.result,
      currentQuery: query,
      cachedResponse: cachedResponse,
    );
  }

  Future<OrchestratorResponse?> executeSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return null;
    }

    if (state.state == DiscoverState.searching) {
      return null;
    }

    // 1. Enter searching state — clear any previous cached response
    _startTimer();
    final localEpoch = ++_requestEpoch;
    state = state.copyWith(
      state: DiscoverState.searching,
      currentQuery: trimmedQuery,
      cachedResponse: null,
    );

    try {
      // 2. Invalidate any cached result for this query so every explicit
      //    search always hits the API fresh, regardless of keepAlive.
      _ref.invalidate(discoverQueryProvider(trimmedQuery));
      final response = await _ref.read(
        discoverQueryProvider(trimmedQuery).future,
      );

      if (localEpoch != _requestEpoch) return null;

      _stopTimer();

      if (response == null) {
        state = DiscoveryStateData();
        return null;
      }

      // 3. Handle response states
      if (response is OrchestratorGeneral ||
          response is OrchestratorSelection) {
        // Happy path: Save to history with full JSON and show results
        final Map<String, dynamic> responseJson;
        if (response is OrchestratorGeneral) {
          responseJson = response.toJson();
        } else {
          responseJson = (response as OrchestratorSelection).toJson();
        }
        final rawJson = jsonEncode(responseJson);
        _ref
            .read(discoverHistoryProvider.notifier)
            .addQuery(trimmedQuery, resultJson: rawJson);
        state = state.copyWith(state: DiscoverState.result);
      } else {
        // Refusal or Error: stay in initial, showing alert is handled by UI
        // We revert to initial state so the input bar and sentences are reset/handled
        state = DiscoveryStateData();
      }
      return response;
    } catch (e) {
      if (localEpoch != _requestEpoch) return null;

      _stopTimer();
      // On error, we always reset to initial so the user can try again
      state = DiscoveryStateData();
      if (e is ServerFailure) {
        return OrchestratorError(
          error: OrchestratorError.serverError,
          details: e.statusCode.toString(),
        );
      } else if (e is NetworkFailure) {
        return const OrchestratorError(error: OrchestratorError.networkError);
      } else if (e is TimeoutFailure) {
        return const OrchestratorError(error: OrchestratorError.timeoutError);
      }
      return OrchestratorError(
        error: OrchestratorError.unknownError,
        details: e.toString(),
      );
    }
  }
}

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryStateData>((ref) {
      return DiscoveryNotifier(ref);
    });
