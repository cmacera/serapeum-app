/// The current Realm schema version.
///
/// Increment this whenever any Realm model changes (fields added/removed/renamed).
/// Used by both the Realm configuration and the backup layer to validate
/// backup compatibility without coupling them to each other.
const int kRealmSchemaVersion = 4;
