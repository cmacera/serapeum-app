import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/local/library_item.dart';
import '../../data/providers/library_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserRatingSection
// ─────────────────────────────────────────────────────────────────────────────

class UserRatingSection extends ConsumerWidget {
  final LibraryItem libraryItem;

  const UserRatingSection({super.key, required this.libraryItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveItem = ref
        .watch(libraryProvider)
        .where(
          (i) =>
              i.externalId == libraryItem.externalId &&
              i.mediaType == libraryItem.mediaType,
        )
        .firstOrNull;
    final currentRating = liveItem?.userRating;
    final globalRating = libraryItem.rating;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRatingDialog(context, ref, currentRating, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (currentRating == null) ...[
                  const Text(
                    '—',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    l10n.libraryRateAction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  Text(
                    currentRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.star, color: Colors.white, size: 20),
                  if (globalRating != null) ...[
                    const SizedBox(width: 12),
                    _DiffBadge(
                      userRating: currentRating,
                      globalRating: globalRating,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(
    BuildContext context,
    WidgetRef ref,
    double? currentRating,
    AppLocalizations l10n,
  ) {
    // Use a transparent page route so the dialog covers the full screen,
    // including the areas behind the status bar and home indicator.
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (ctx, anim, secAnim) => _RatingDialog(
          libraryItem: libraryItem,
          currentRating: currentRating,
          l10n: l10n,
          onSave: (rating) => ref
              .read(libraryProvider.notifier)
              .updateUserRating(
                libraryItem.externalId,
                libraryItem.mediaType,
                rating,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DiffBadge
// ─────────────────────────────────────────────────────────────────────────────

class _DiffBadge extends StatelessWidget {
  final double userRating;
  final double globalRating;

  const _DiffBadge({required this.userRating, required this.globalRating});

  @override
  Widget build(BuildContext context) {
    final diff = userRating - globalRating;
    if (diff.abs() < 0.05) return const SizedBox.shrink();
    final isPositive = diff > 0;
    final label = '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}';
    final color = isPositive ? Colors.green.shade300 : Colors.red.shade300;
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RatingDialog — full-screen modal with blurred backdrop + drag stars
// ─────────────────────────────────────────────────────────────────────────────

class _RatingDialog extends StatefulWidget {
  final LibraryItem libraryItem;
  final double? currentRating;
  final AppLocalizations l10n;
  final void Function(double? rating) onSave;

  const _RatingDialog({
    required this.libraryItem,
    required this.currentRating,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    // Round initial value to nearest 0.1
    final initial = widget.currentRating?.clamp(0.1, 10.0) ?? 5.0;
    _rating = (initial * 10).round() / 10.0;
  }

  // Convert a horizontal drag/tap position to a 0.1-precision rating (0.1–10)
  double _ratingFromOffset(double dx, double totalWidth) {
    final raw = (dx / totalWidth) * 10.0;
    final clamped = raw.clamp(0.1, 10.0);
    return (clamped * 10).round() / 10.0;
  }

  // Full star if the star is completely covered, half if partially, empty otherwise.
  IconData _starIcon(int index) {
    if (_rating >= index + 1.0) return Icons.star_rounded;
    if (_rating > index.toDouble()) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  Color _starColor(int index) {
    return _rating > index.toDouble()
        ? Colors.amber
        : Colors.white.withValues(alpha: 0.35);
  }

  String _displayRating() {
    if (_rating % 1 == 0) return _rating.toInt().toString();
    return _rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final imageUrl = widget.libraryItem.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    // Manual safe-area insets — avoids SafeArea which was preventing full bleed.
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: blurred cover image ──────────────────────────────
          if (hasImage)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (ctx, url) => Container(color: Colors.black),
              errorWidget: (ctx, url, err) => Container(color: Colors.black),
            )
          else
            Container(color: Colors.black),

          // ── Blur + dark tint ─────────────────────────────────────────────
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(color: Colors.black.withValues(alpha: 0.65)),
          ),

          // ── Foreground content ───────────────────────────────────────────
          Column(
            children: [
              // Status-bar spacer + top bar
              SizedBox(height: viewPadding.top + 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.libraryItem.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // Visually balance the close button
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Cover image
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 80),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) =>
                            Container(color: Colors.black26),
                        errorWidget: (ctx, url, err) => Container(
                          color: Colors.black26,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Current rating number (no "/10" — always out of 10)
              Text(
                _displayRating(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),

              const SizedBox(height: 28),

              // Drag-enabled star slider (0.1 precision)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final totalWidth = constraints.maxWidth;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => setState(
                        () => _rating = _ratingFromOffset(
                          d.localPosition.dx,
                          totalWidth,
                        ),
                      ),
                      onHorizontalDragUpdate: (d) => setState(
                        () => _rating = _ratingFromOffset(
                          d.localPosition.dx,
                          totalWidth,
                        ),
                      ),
                      child: Row(
                        children: List.generate(
                          10,
                          (i) => Expanded(
                            child: Icon(
                              _starIcon(i),
                              color: _starColor(i),
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Action buttons + home-indicator spacer
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, viewPadding.bottom + 8),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          widget.onSave(_rating);
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onSave(null);
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.libraryRatingClear,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserReviewSection
// ─────────────────────────────────────────────────────────────────────────────

class UserReviewSection extends ConsumerWidget {
  final LibraryItem libraryItem;

  const UserReviewSection({super.key, required this.libraryItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveItem = ref
        .watch(libraryProvider)
        .where(
          (i) =>
              i.externalId == libraryItem.externalId &&
              i.mediaType == libraryItem.mediaType,
        )
        .firstOrNull;
    final currentNote = liveItem?.userNote;
    final l10n = AppLocalizations.of(context)!;
    final darkColor = Colors.grey.shade900;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showNoteDialog(context, ref, currentNote, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: currentNote == null || currentNote.isEmpty
                ? Row(
                    children: [
                      Icon(Icons.edit_note, color: darkColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        l10n.libraryAddNoteButton,
                        style: TextStyle(
                          color: darkColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    currentNote,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: darkColor,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    WidgetRef ref,
    String? currentNote,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _NoteDialog(
        initialNote: currentNote ?? '',
        l10n: l10n,
        onSave: (note) => ref
            .read(libraryProvider.notifier)
            .updateUserNote(
              libraryItem.externalId,
              libraryItem.mediaType,
              note,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoteDialog
// ─────────────────────────────────────────────────────────────────────────────

class _NoteDialog extends StatefulWidget {
  final String initialNote;
  final AppLocalizations l10n;
  final void Function(String note) onSave;

  const _NoteDialog({
    required this.initialNote,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.libraryUserReviewLabel),
      content: TextField(
        controller: _controller,
        maxLines: 6,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.libraryAddNoteButton,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
          onPressed: () {
            widget.onSave(_controller.text);
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
