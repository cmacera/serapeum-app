import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/media_card_type.dart';
import '../../data/local/library_item.dart';
import '../../data/providers/library_provider.dart';

const _kEmDash = '—';

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentRating == null) ...[
                      const Text(
                        _kEmDash,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.star, color: Colors.white, size: 20),
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
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (currentRating == null)
                  Text(
                    l10n.libraryRateAction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (globalRating != null)
                  _DiffBadge(
                    userRating: currentRating,
                    globalRating: globalRating,
                  )
                else
                  const SizedBox.shrink(),
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
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
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
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
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
// _FractionClipper — clips a widget to a horizontal fraction (0.0–1.0)
// ─────────────────────────────────────────────────────────────────────────────

class _FractionClipper extends CustomClipper<Rect> {
  final double fraction;

  const _FractionClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_FractionClipper old) => old.fraction != fraction;
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
    final initial = widget.currentRating?.clamp(0.1, 10.0) ?? 5.0;
    _rating = (initial * 10).round() / 10.0;
  }

  double _ratingFromOffset(double dx, double totalWidth) {
    final raw = (dx / totalWidth) * 10.0;
    final clamped = raw.clamp(0.1, 10.0);
    return (clamped * 10).round() / 10.0;
  }

  /// Fill fraction for star at [index]: 0.0 = empty, 1.0 = full, 0.3 = 30%.
  double _starFill(int index) => (_rating - index).clamp(0.0, 1.0);

  String _displayRating() {
    if (_rating % 1 == 0) return _rating.toInt().toString();
    return _rating.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final imageUrl = widget.libraryItem.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
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

              // Current rating number
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

              // Drag-enabled star slider — 0.1 precision via fractional clip
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
                        children: List.generate(10, (i) {
                          final fill = _starFill(i);
                          return Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.star_outline_rounded,
                                  color: Colors.white.withValues(alpha: 0.35),
                                  size: 38,
                                ),
                                if (fill > 0)
                                  ClipRect(
                                    clipper: _FractionClipper(fill),
                                    child: const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 38,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),

              // Action buttons
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
// UserConsumedSection
// ─────────────────────────────────────────────────────────────────────────────

class UserConsumedSection extends ConsumerWidget {
  final LibraryItem libraryItem;
  final MediaCardType mediaType;

  const UserConsumedSection({
    super.key,
    required this.libraryItem,
    required this.mediaType,
  });

  Color get _consumedColor => switch (mediaType) {
    MediaCardType.movie || MediaCardType.tv => AppColors.badgeMedia,
    MediaCardType.book => AppColors.badgeBook,
    MediaCardType.game => AppColors.badgeGame,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final liveItem = ref
        .watch(libraryProvider)
        .where(
          (i) =>
              i.externalId == libraryItem.externalId &&
              i.mediaType == libraryItem.mediaType,
        )
        .firstOrNull;
    final consumed = liveItem?.isConsumed ?? false;
    final l10n = AppLocalizations.of(context)!;

    final (
      IconData icon,
      String labelConsumed,
      String labelMark,
    ) = switch (mediaType) {
      MediaCardType.movie || MediaCardType.tv => (
        Icons.visibility,
        l10n.libraryWatched,
        l10n.libraryMarkAsWatched,
      ),
      MediaCardType.book => (
        Icons.menu_book_outlined,
        l10n.libraryRead,
        l10n.libraryMarkAsRead,
      ),
      MediaCardType.game => (
        Icons.sports_esports_outlined,
        l10n.libraryPlayed,
        l10n.libraryMarkAsPlayed,
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ref
            .read(libraryProvider.notifier)
            .updateIsConsumed(
              libraryItem.externalId,
              libraryItem.mediaType,
              !consumed,
            ),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: consumed
                ? _consumedColor
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  consumed ? Icons.check_circle : icon,
                  color: consumed
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(height: 6),
                Text(
                  consumed ? labelConsumed : labelMark,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: consumed
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: consumed ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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
        onTap: () => _showNoteEditor(context, ref, currentNote, l10n),
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

  void _showNoteEditor(
    BuildContext context,
    WidgetRef ref,
    String? currentNote,
    AppLocalizations l10n,
  ) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (ctx, anim, secAnim) => _NoteEditor(
          libraryItem: libraryItem,
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
        transitionsBuilder: (ctx, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoteEditor — full-screen modal with blurred backdrop + text field
// ─────────────────────────────────────────────────────────────────────────────

class _NoteEditor extends StatefulWidget {
  final LibraryItem libraryItem;
  final String initialNote;
  final AppLocalizations l10n;
  final void Function(String note) onSave;

  const _NoteEditor({
    required this.libraryItem,
    required this.initialNote,
    required this.l10n,
    required this.onSave,
  });

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(_controller.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final imageUrl = widget.libraryItem.imageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final bottomInset = math.max(keyboardHeight, viewPadding.bottom) + 8;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ───────────────────────────────────────────────────
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
            child: Container(color: Colors.black.withValues(alpha: 0.78)),
          ),

          // ── Foreground content ───────────────────────────────────────────
          Column(
            children: [
              SizedBox(height: viewPadding.top + 4),

              // Top bar: close | title | save
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
                          fontSize: 18,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _save,
                      child: Text(
                        l10n.save,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white12, height: 1),

              // Text field — fills remaining space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.65,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: l10n.libraryAddNoteButton,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),

              // Bottom actions — rise above keyboard
              Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          widget.onSave('');
                          Navigator.pop(context);
                        },
                        child: Text(l10n.libraryRatingClear),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(
                          l10n.save,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
