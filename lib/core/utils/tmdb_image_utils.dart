import '../constants/api_constants.dart';

String? tmdbPosterUrl(String? path) => path != null
    ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW500}$path'
    : null;

String? tmdbBackdropUrl(String? path) => path != null
    ? '${ApiConstants.tmdbImageBaseUrl}${ApiConstants.tmdbImageTierW780}$path'
    : null;
