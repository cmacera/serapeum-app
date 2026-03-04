import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../domain/entities/book.dart';
import 'detail_section_widgets.dart';

const _kMaturityNotMature = 'NOT_MATURE';

class BookInfoSection extends StatelessWidget {
  final Book book;

  const BookInfoSection({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authorList =
        book.authors?.where((a) => a.trim().isNotEmpty).toList() ?? [];
    final authors = authorList.isNotEmpty
        ? authorList.join(', ')
        : l10n.unknownAuthors;
    final publisherTrimmed = book.publisher?.trim() ?? '';
    final publisher = publisherTrimmed.isNotEmpty
        ? publisherTrimmed
        : l10n.unknownPublisher;
    final maturity = book.maturityRating?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoSection(
          title: l10n.detailPublishingInfo,
          content:
              '${l10n.detailAuthors}: $authors\n${l10n.detailPublisher}: $publisher'
              '${book.isbn != null && book.isbn!.trim().isNotEmpty ? '\n${l10n.detailIsbn}: ${book.isbn!.trim()}' : ''}',
        ),
        if (maturity.isNotEmpty) ...[
          SectionTitle(title: l10n.detailMaturityRating),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                maturity == _kMaturityNotMature
                    ? Icons.child_care
                    : Icons.explicit,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              AgeRatingChip(
                label: maturity == _kMaturityNotMature
                    ? l10n.maturityRatingForAll
                    : l10n.maturityRatingMature,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
