import 'package:freezed_annotation/freezed_annotation.dart';

part 'book_mark_response_data.freezed.dart';
part 'book_mark_response_data.g.dart';

@freezed
class BookMarkResponseData with _$BookMarkResponseData {
  const factory BookMarkResponseData({
    required bool success,
    required bool bookmarked,
    required String message,
  }) = _BookMarkResponseData;

  factory BookMarkResponseData.fromJson(Map<String, dynamic> json) =>
      _$BookMarkResponseDataFromJson(json);
}
