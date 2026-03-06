import 'package:equatable/equatable.dart';
import 'book.dart';
import 'game.dart';
import 'media.dart';
import 'search_all_response.dart';

sealed class OrchestratorResponse extends Equatable {
  const OrchestratorResponse();

  @override
  List<Object?> get props => [];
}

class OrchestratorMessage extends OrchestratorResponse {
  final String text;
  const OrchestratorMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class OrchestratorGeneral extends OrchestratorResponse {
  final String text;
  final SearchAllResponse data;
  const OrchestratorGeneral({required this.text, required this.data});

  @override
  List<Object?> get props => [text, data];

  Map<String, dynamic> toJson() => {
    'kind': 'search_results',
    'message': text,
    'data': data.toJson(),
  };
}

class OrchestratorSelection extends OrchestratorResponse {
  final List<Book>? books;
  final List<Media>? media;
  final List<Game>? games;

  const OrchestratorSelection({this.books, this.media, this.games});

  @override
  List<Object?> get props => [books, media, games];

  Map<String, dynamic> toJson() => {
    'kind': 'discovery',
    'message': '',
    'data': SearchAllResponse(
      media: media ?? [],
      books: books ?? [],
      games: games ?? [],
    ).toJson(),
  };
}

class OrchestratorError extends OrchestratorResponse {
  static const String serverError = 'SERVER_ERROR';
  static const String networkError = 'NETWORK_ERROR';
  static const String timeoutError = 'TIMEOUT_ERROR';
  static const String unknownError = 'UNKNOWN_ERROR';

  final String error;
  final String? details;
  const OrchestratorError({required this.error, this.details});

  @override
  List<Object?> get props => [error, details];
}
