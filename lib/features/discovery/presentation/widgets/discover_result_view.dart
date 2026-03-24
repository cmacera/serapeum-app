import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../domain/entities/orchestrator_response.dart';
import '../../domain/entities/search_all_response.dart';
import '../providers/discovery_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/feedback_buttons.dart';
import 'discover_result_list.dart';

class DiscoverResultView extends ConsumerWidget {
  final String query;

  const DiscoverResultView({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final discoveryState = ref.watch(discoveryProvider);
    final cached = discoveryState.cachedResponse;

    if (cached != null) {
      return _buildFromData(context, cached, l10n);
    }

    // Should not happen, but we provide a fallback error message
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ChatMessageBubble(text: query, isUser: true),
        const SizedBox(height: 16),
        ChatMessageBubble(text: l10n.noResponseFromOracle, isUser: false),
      ],
    );
  }

  Widget _buildFromData(
    BuildContext context,
    OrchestratorResponse data,
    AppLocalizations l10n,
  ) {
    return switch (data) {
      OrchestratorMessage(text: final text, traceId: final traceId) => ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ChatMessageBubble(text: query, isUser: true),
          const SizedBox(height: 16),
          ChatMessageBubble(text: text, isUser: false),
          FeedbackButtons(traceId: traceId),
        ],
      ),
      OrchestratorGeneral(
        text: final text,
        data: final searchData,
        traceId: final traceId,
      ) =>
        DiscoverResultList(
          query: query,
          assistantText: text,
          response: searchData,
          traceId: traceId,
        ),
      OrchestratorSelection(
        books: final books,
        media: final media,
        games: final games,
        traceId: final traceId,
      ) =>
        DiscoverResultList(
          query: query,
          assistantText: l10n.resultIntro,
          response: SearchAllResponse(
            books: books ?? [],
            media: media ?? [],
            games: games ?? [],
          ),
          traceId: traceId,
        ),
      OrchestratorError(error: final error, details: final details) => ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ChatMessageBubble(text: query, isUser: true),
          const SizedBox(height: 16),
          ChatMessageBubble(
            text: l10n.oracleErrorTemplate(
              error,
              (details != null && details.isNotEmpty) ? '\n$details' : '',
            ),
            isUser: false,
          ),
        ],
      ),
    };
  }
}
