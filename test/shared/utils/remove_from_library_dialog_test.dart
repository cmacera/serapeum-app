import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/l10n/app_localizations.dart';
import 'package:serapeum_app/shared/utils/remove_from_library_dialog.dart';

Widget _wrap(VoidCallback onConfirmed) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('en'),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () =>
            showRemoveFromLibraryDialog(context, 'Inception', onConfirmed),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  group('showRemoveFromLibraryDialog', () {
    testWidgets('shows dialog with item title', (tester) async {
      await tester.pumpWidget(_wrap(() {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Inception'), findsOneWidget);
    });

    testWidgets('shows confirm and cancel buttons', (tester) async {
      await tester.pumpWidget(_wrap(() {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.text('Inception')))!;
      expect(find.text(l10n.removeFromLibrary), findsWidgets);
      expect(find.text(l10n.cancel), findsOneWidget);
    });

    testWidgets('calls onConfirmed when confirm button is tapped', (
      tester,
    ) async {
      var confirmed = false;
      await tester.pumpWidget(_wrap(() => confirmed = true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.text('Inception')))!;
      // The confirm button is the last widget with the removeFromLibrary label
      await tester.tap(find.text(l10n.removeFromLibrary).last);
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });

    testWidgets('does NOT call onConfirmed when cancel is tapped', (
      tester,
    ) async {
      var confirmed = false;
      await tester.pumpWidget(_wrap(() => confirmed = true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.text('Inception')))!;
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();

      expect(confirmed, isFalse);
    });

    testWidgets('dismisses dialog after confirm', (tester) async {
      await tester.pumpWidget(_wrap(() {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.text('Inception')))!;
      await tester.tap(find.text(l10n.removeFromLibrary).last);
      await tester.pumpAndSettle();

      expect(find.text('Inception'), findsNothing);
    });

    testWidgets('dismisses dialog after cancel', (tester) async {
      await tester.pumpWidget(_wrap(() {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.text('Inception')))!;
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();

      expect(find.text('Inception'), findsNothing);
    });
  });
}
