import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../domain/entities/orchestrator_response.dart';
import '../../domain/entities/search_all_response.dart';
import '../providers/discover_query_provider.dart';
import '../providers/discovery_provider.dart';
import '../widgets/chat_message_bubble.dart';
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

    final responseAsync = ref.watch(discoverQueryProvider(query));

    return responseAsync.when(
      data: (data) {
        if (data == null) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ChatMessageBubble(text: query, isUser: true),
              const SizedBox(height: 16),
              Center(child: Text(l10n.noResponseFromOracle)),
            ],
          );
        }

        return _buildFromData(context, data, l10n);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) {
        debugPrint('Error querying the Oracle: $err\n$stack');
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ChatMessageBubble(text: query, isUser: true),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChatMessageBubble(text: l10n.queryFailed, isUser: false),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFromData(
    BuildContext context,
    OrchestratorResponse data,
    AppLocalizations l10n,
  ) {
    return switch (data) {
      OrchestratorMessage(text: final text) => ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ChatMessageBubble(text: query, isUser: true),
          const SizedBox(height: 16),
          ChatMessageBubble(text: text, isUser: false),
        ],
      ),
      OrchestratorGeneral(text: final text, data: final searchData) =>
        DiscoverResultList(
          query: query,
          assistantText: text,
          response: searchData,
        ),
      OrchestratorSelection(
        books: final books,
        media: final media,
        games: final games,
      ) =>
        DiscoverResultList(
          query: query,
          assistantText: l10n.resultIntro,
          response: SearchAllResponse(
            books: books ?? [],
            media: media ?? [],
            games: games ?? [],
          ),
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
