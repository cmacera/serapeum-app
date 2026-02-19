import 'package:json_annotation/json_annotation.dart';

part 'catalog_search_input_dto.g.dart';

/// Request body DTO for all search endpoints.
///
/// Serialization-only — use [toJson] to build the POST body.
@JsonSerializable(createFactory: false, includeIfNull: false)
class CatalogSearchInputDto {
  final String query;
  final String? language;

  const CatalogSearchInputDto({required this.query, this.language});

  Map<String, dynamic> toJson() => _$CatalogSearchInputDtoToJson(this);
}
