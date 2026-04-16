/// Wraps a single page of results from a paginated API endpoint.
class PaginatedResult<T> {
  final List<T> results;
  final int page;
  final bool hasMore;
  final int? total;

  const PaginatedResult({
    required this.results,
    required this.page,
    required this.hasMore,
    this.total,
  });
}
