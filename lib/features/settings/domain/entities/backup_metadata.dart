class BackupMetadata {
  const BackupMetadata({
    required this.createdAt,
    required this.itemCount,
    required this.schemaVersion,
  });

  final DateTime createdAt;
  final int itemCount;
  final int schemaVersion;

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      createdAt: DateTime.parse(json['created_at'] as String),
      itemCount: json['item_count'] as int,
      schemaVersion: json['schema_version'] as int,
    );
  }
}
