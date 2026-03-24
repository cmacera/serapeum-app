import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/providers/discovery_providers.dart';

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
  int? _submitted; // null = not yet sent, 1 = thumbs up, 0 = thumbs down

  Future<void> _submit(int score) async {
    final traceId = widget.traceId;
    if (_submitted != null || traceId == null) return;
    setState(() => _submitted = score);
    try {
      await ref
          .read(catalogDiscoverRepositoryProvider)
          .submitFeedback(traceId: traceId, score: score);
    } catch (_) {
      // Silent failure per acceptance criteria
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.traceId == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _submitted == 1 ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: _submitted == 1 ? AppColors.accent : Colors.white38,
              semanticLabel: 'Good response',
            ),
            onPressed: _submitted == null ? () => _submit(1) : null,
            tooltip: 'Good response',
          ),
          IconButton(
            iconSize: 20,
            visualDensity: VisualDensity.compact,
            icon: Icon(
              _submitted == 0 ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: _submitted == 0 ? AppColors.accent : Colors.white38,
              semanticLabel: 'Bad response',
            ),
            onPressed: _submitted == null ? () => _submit(0) : null,
            tooltip: 'Bad response',
          ),
        ],
      ),
    );
  }
}
