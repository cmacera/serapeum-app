import 'package:flutter_test/flutter_test.dart';
import 'package:serapeum_app/features/settings/domain/entities/backup_metadata.dart';

void main() {
  group('BackupMetadata.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'schema_version': 4,
        'created_at': '2026-04-11T10:00:00.000Z',
        'item_count': 42,
      };

      final metadata = BackupMetadata.fromJson(json);

      expect(metadata.schemaVersion, 4);
      expect(metadata.itemCount, 42);
      expect(metadata.createdAt, DateTime.utc(2026, 4, 11, 10, 0, 0));
    });

    test('parses zero item count', () {
      final json = {
        'schema_version': 4,
        'created_at': '2026-01-01T00:00:00.000Z',
        'item_count': 0,
      };

      final metadata = BackupMetadata.fromJson(json);

      expect(metadata.itemCount, 0);
    });

    test('preserves UTC timestamp', () {
      final json = {
        'schema_version': 4,
        'created_at': '2026-04-11T15:30:00.000Z',
        'item_count': 1,
      };

      final metadata = BackupMetadata.fromJson(json);

      expect(metadata.createdAt.isUtc, isTrue);
      expect(metadata.createdAt.hour, 15);
      expect(metadata.createdAt.minute, 30);
    });

    test('throws when created_at is not a valid date', () {
      final json = {
        'schema_version': 4,
        'created_at': 'not-a-date',
        'item_count': 1,
      };

      expect(
        () => BackupMetadata.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
