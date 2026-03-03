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
    final authors = book.authors?.join(', ') ?? l10n.unknownAuthors;
    final publisher = book.publisher ?? l10n.unknownPublisher;
    return InfoSection(
      title: l10n.detailPublishingInfo,
      content:
          '${l10n.detailAuthors}: $authors\n${l10n.detailPublisher}: $publisher'
          '${book.isbn != null ? '\nISBN: ${book.isbn}' : ''}',
    );
  }
}
