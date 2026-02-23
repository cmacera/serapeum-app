import 'book.dart';
import 'game.dart';
import 'media.dart';
import 'search_all_response.dart';

sealed class OrchestratorResponse {
  const OrchestratorResponse();
}

class OrchestratorMessage extends OrchestratorResponse {
  final String text;
  const OrchestratorMessage(this.text);
}

class OrchestratorGeneral extends OrchestratorResponse {
  final String text;
  final SearchAllResponse data;
  const OrchestratorGeneral({required this.text, required this.data});
}

class OrchestratorSelection extends OrchestratorResponse {
  final List<Book>? books;
  final List<Media>? media;
  final List<Game>? games;

  const OrchestratorSelection({this.books, this.media, this.games});
}

class OrchestratorError extends OrchestratorResponse {
  final String error;
  final String? details;
  const OrchestratorError({required this.error, this.details});
}
