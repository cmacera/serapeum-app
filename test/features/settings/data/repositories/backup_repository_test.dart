import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:realm/realm.dart' hide User;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:serapeum_app/core/network/failure.dart';
import 'package:serapeum_app/core/realm/realm_schema_version.dart';
import 'package:serapeum_app/features/library/data/local/library_item.dart';
import 'package:serapeum_app/features/settings/data/repositories/backup_repository.dart';
import 'package:serapeum_app/features/settings/domain/repositories/i_backup_repository.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockRealm extends Mock implements Realm {}

class _MockRealmResults extends Mock implements RealmResults<LibraryItem> {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates a minimal valid gotrue [User] instance with the given [id].
User _fakeUser(String id) => User(
  id: id,
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  createdAt: '2026-01-01T00:00:00Z',
);

Map<String, dynamic> _validPayload({
  int itemCount = 0,
  int schemaVersion = kRealmSchemaVersion,
}) => {
  'schema_version': schemaVersion,
  'created_at': '2026-04-11T10:00:00.000Z',
  'item_count': itemCount,
  'items': [],
};

Uint8List _encode(Map<String, dynamic> json) =>
    Uint8List.fromList(utf8.encode(jsonEncode(json)));

RealmResults<LibraryItem> _emptyResults() {
  final mock = _MockRealmResults();
  when(() => mock.toList()).thenReturn([]);
  return mock;
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockStorageFileApi mockFileApi;
  late MockRealm mockRealm;
  late BackupRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockFileApi = MockStorageFileApi();
    mockRealm = MockRealm();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(
      () => mockSupabase.storage,
    ).thenReturn(_FakeStorageClient(mockFileApi));

    repository = BackupRepository(mockSupabase);

    registerFallbackValue(
      const FileOptions(contentType: 'application/json', upsert: true),
    );
    registerFallbackValue(Uint8List(0));
  });

  // ---------------------------------------------------------------------------
  // _requireUserId
  // ---------------------------------------------------------------------------

  group('_requireUserId', () {
    test('throws BackupNotAuthenticatedException when currentUser is null', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.createBackup(mockRealm),
        throwsA(isA<BackupNotAuthenticatedException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createBackup
  // ---------------------------------------------------------------------------

  group('createBackup', () {
    setUp(() {
      // Pre-compute to avoid calling when() inside thenReturn()'s argument.
      final emptyResults = _emptyResults();
      when(() => mockAuth.currentUser).thenReturn(_fakeUser('user-abc'));
      when(() => mockRealm.all<LibraryItem>()).thenReturn(emptyResults);
      when(
        () => mockFileApi.uploadBinary(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'user-abc/library_backup.json');
    });

    test('uploads to the correct user-scoped path', () async {
      await repository.createBackup(mockRealm);

      verify(
        () => mockFileApi.uploadBinary(
          'user-abc/library_backup.json',
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).called(1);
    });

    test('uploaded JSON contains schema_version and item_count', () async {
      List<int>? capturedBytes;
      when(
        () => mockFileApi.uploadBinary(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((inv) async {
        capturedBytes = inv.positionalArguments[1] as List<int>;
        return 'user-abc/library_backup.json';
      });

      await repository.createBackup(mockRealm);

      final decoded =
          jsonDecode(utf8.decode(capturedBytes!)) as Map<String, dynamic>;
      expect(decoded['schema_version'], 4);
      expect(decoded['item_count'], 0);
      expect(decoded['items'], isEmpty);
    });

    test('uses upsert:true to overwrite existing backup', () async {
      FileOptions? capturedOptions;
      when(
        () => mockFileApi.uploadBinary(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((inv) async {
        capturedOptions = inv.namedArguments[#fileOptions] as FileOptions?;
        return 'user-abc/library_backup.json';
      });

      await repository.createBackup(mockRealm);

      expect(capturedOptions?.upsert, isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // getBackupMetadata
  // ---------------------------------------------------------------------------

  group('getBackupMetadata', () {
    setUp(() {
      when(() => mockAuth.currentUser).thenReturn(_fakeUser('user-abc'));
    });

    test('returns metadata when backup exists', () async {
      when(
        () => mockFileApi.download('user-abc/library_backup.json'),
      ).thenAnswer((_) async => _encode(_validPayload(itemCount: 7)));

      final metadata = await repository.getBackupMetadata();

      expect(metadata, isNotNull);
      expect(metadata!.itemCount, 7);
      expect(metadata.schemaVersion, 4);
    });

    test('returns null on 404 StorageException', () async {
      when(
        () => mockFileApi.download(any()),
      ).thenThrow(StorageException('Not found', statusCode: '404'));

      final metadata = await repository.getBackupMetadata();

      expect(metadata, isNull);
    });

    test('returns null when message contains "not found"', () async {
      when(
        () => mockFileApi.download(any()),
      ).thenThrow(StorageException('Object not found'));

      final metadata = await repository.getBackupMetadata();

      expect(metadata, isNull);
    });

    test('throws ServerFailure on non-404 StorageExceptions', () {
      when(
        () => mockFileApi.download(any()),
      ).thenThrow(StorageException('Server error', statusCode: '500'));

      expect(
        () => repository.getBackupMetadata(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // restoreBackup
  // ---------------------------------------------------------------------------

  group('restoreBackup', () {
    setUp(() {
      when(() => mockAuth.currentUser).thenReturn(_fakeUser('user-abc'));
    });

    test(
      'throws BackupIncompatibleSchemaException on schema_version > current',
      () {
        final incompatible = {
          'schema_version': kRealmSchemaVersion + 1,
          'created_at': '2026-04-11T10:00:00.000Z',
          'item_count': 0,
          'items': [],
        };
        when(
          () => mockFileApi.download(any()),
        ).thenAnswer((_) async => _encode(incompatible));

        expect(
          () => repository.restoreBackup(mockRealm),
          throwsA(isA<BackupIncompatibleSchemaException>()),
        );
      },
    );

    test('writes to realm when backup is valid', () async {
      when(
        () => mockFileApi.download(any()),
      ).thenAnswer((_) async => _encode(_validPayload()));
      // Dart infers the write callback as Null, not void.
      when(() => mockRealm.write<Null>(any())).thenAnswer((inv) {
        (inv.positionalArguments[0] as Function())();
      });
      when(() => mockRealm.deleteAll<LibraryItem>()).thenReturn(null);
      when(() => mockRealm.addAll<LibraryItem>(any())).thenReturn(null);

      await repository.restoreBackup(mockRealm);

      verify(() => mockRealm.write<Null>(any())).called(1);
    });

    test('downloads from correct user-scoped path', () async {
      when(
        () => mockFileApi.download(any()),
      ).thenAnswer((_) async => _encode(_validPayload()));
      when(() => mockRealm.write<Null>(any())).thenAnswer((inv) {
        (inv.positionalArguments[0] as Function())();
      });
      when(() => mockRealm.deleteAll<LibraryItem>()).thenReturn(null);
      when(() => mockRealm.addAll<LibraryItem>(any())).thenReturn(null);

      await repository.restoreBackup(mockRealm);

      verify(
        () => mockFileApi.download('user-abc/library_backup.json'),
      ).called(1);
    });

    // Schema boundary tests ------------------------------------------------

    void stubSuccessfulWrite() {
      when(() => mockRealm.write<Null>(any())).thenAnswer((inv) {
        (inv.positionalArguments[0] as Function())();
      });
      when(() => mockRealm.deleteAll<LibraryItem>()).thenReturn(null);
      when(() => mockRealm.addAll<LibraryItem>(any())).thenReturn(null);
    }

    test('restores when schema_version == kRealmSchemaVersion', () async {
      when(() => mockFileApi.download(any())).thenAnswer(
        (_) async => _encode(_validPayload(schemaVersion: kRealmSchemaVersion)),
      );
      stubSuccessfulWrite();

      await expectLater(repository.restoreBackup(mockRealm), completes);
    });

    test('restores when schema_version < kRealmSchemaVersion', () async {
      final olderBackup = {
        'schema_version': kRealmSchemaVersion - 1,
        'created_at': '2026-04-11T10:00:00.000Z',
        'item_count': 0,
        'items': [],
      };
      when(
        () => mockFileApi.download(any()),
      ).thenAnswer((_) async => _encode(olderBackup));
      stubSuccessfulWrite();

      await expectLater(repository.restoreBackup(mockRealm), completes);
    });

    test(
      'throws BackupIncompatibleSchemaException when schema_version is null',
      () {
        final nullSchemaBackup = {
          'schema_version': null,
          'created_at': '2026-04-11T10:00:00.000Z',
          'item_count': 0,
          'items': [],
        };
        when(
          () => mockFileApi.download(any()),
        ).thenAnswer((_) async => _encode(nullSchemaBackup));

        expect(
          () => repository.restoreBackup(mockRealm),
          throwsA(isA<BackupIncompatibleSchemaException>()),
        );
      },
    );
  });
}

// ---------------------------------------------------------------------------
// Test doubles
// ---------------------------------------------------------------------------

/// Fakes SupabaseStorageClient.from() without implementing the sealed class.
class _FakeStorageClient extends Fake implements SupabaseStorageClient {
  _FakeStorageClient(this._fileApi);
  final StorageFileApi _fileApi;

  @override
  StorageFileApi from(String id) => _fileApi;
}
