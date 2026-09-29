import 'package:freezed_annotation/freezed_annotation.dart';

part 'music_search_response.freezed.dart';
part 'music_search_response.g.dart';

@freezed
class MusicSearchResponse with _$MusicSearchResponse {
  const factory MusicSearchResponse({
    required bool success,
    required int count,
    required List<MusicData> data,
  }) = _MusicSearchResponse;

  factory MusicSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MusicSearchResponseFromJson(json);
}

@freezed
class MusicData with _$MusicData {
  const factory MusicData({
    required String thirdPartyId,
    required String title,
    required String artist,
    String? coverImage,
    required String audioUrl,
  }) = _MusicData;

  factory MusicData.fromJson(Map<String, dynamic> json) =>
      _$MusicDataFromJson(json);
}
