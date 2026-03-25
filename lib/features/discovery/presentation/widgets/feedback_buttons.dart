import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/providers/discovery_providers.dart';
import '../../domain/entities/feedback_score.dart';

/// Shows 👍/👎 buttons below an agent response bubble.
///
/// If [traceId] is null (e.g. a history item), renders nothing.
/// Once a button is tapped, both are disabled and the selected icon fills.
/// Failures are swallowed silently — feedback is non-critical UX.
class FeedbackButtons extends ConsumerStatefulWidget {
  final String? traceId;

  const FeedbackButtons({super.key, this.traceId});

  @override
  ConsumerState<FeedbackButtons> createState() => _FeedbackButtonsState();
}

class _FeedbackButtonsState extends ConsumerState<FeedbackButtons> {
  FeedbackScore? _submitted;

  Future<void> _submit(FeedbackScore score) async {
    final traceId = widget.traceId;
    if (_submitted != null || traceId == null) return;
    setState(() => _submitted = score);
    try {
      await ref
          .read(catalogDiscoverRepositoryProvider)
          .submitFeedback(traceId: traceId, score: score);
    } catch (_) {
      // Revert so the user can retry — failure is still silent per AC.
      setState(() => _submitted = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final traceId = widget.traceId;
    if (traceId == null || traceId.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _submitted == FeedbackScore.up
                  ? Icons.thumb_up
                  : Icons.thumb_up_outlined,
              color: _submitted == FeedbackScore.up
                  ? AppColors.accent
                  : Colors.white38,
              semanticLabel: l10n.feedbackGoodResponse,
            ),
            onPressed: _submitted == null
                ? () => _submit(FeedbackScore.up)
                : null,
            tooltip: l10n.feedbackGoodResponse,
          ),
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _submitted == FeedbackScore.down
                  ? Icons.thumb_down
                  : Icons.thumb_down_outlined,
              color: _submitted == FeedbackScore.down
                  ? AppColors.accent
                  : Colors.white38,
              semanticLabel: l10n.feedbackBadResponse,
            ),
            onPressed: _submitted == null
                ? () => _submit(FeedbackScore.down)
                : null,
            tooltip: l10n.feedbackBadResponse,
          ),
        ],
      ),
    );
  }
}
