import 'package:flutter/material.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';

import '../../../domain/entities/book.dart';
import 'detail_section_widgets.dart';

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
    return InfoSection(
      title: l10n.detailPublishingInfo,
      content:
          '${l10n.detailAuthors}: $authors\n${l10n.detailPublisher}: $publisher'
          '${book.isbn != null && book.isbn!.trim().isNotEmpty ? '\n${l10n.detailIsbn}: ${book.isbn}' : ''}',
    );
  }
}
