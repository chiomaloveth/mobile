import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_comment_response_data.freezed.dart';
part 'delete_comment_response_data.g.dart';

@freezed
class DeleteCommentResponseData with _$DeleteCommentResponseData {
  const factory DeleteCommentResponseData({
    required String message,
  }) = _DeleteCommentResponseData;

  factory DeleteCommentResponseData.fromJson(Map<String, dynamic> json) => _$DeleteCommentResponseDataFromJson(json);
}