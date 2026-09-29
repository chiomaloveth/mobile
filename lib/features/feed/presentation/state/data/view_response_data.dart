import 'package:freezed_annotation/freezed_annotation.dart';

part 'view_response_data.freezed.dart';
part 'view_response_data.g.dart';

@freezed
class ViewResponseData with _$ViewResponseData {
  const factory ViewResponseData({
    required bool success,
    required String message,
  }) = _ViewResponseData;

  factory ViewResponseData.fromJson(Map<String, dynamic> json) => _$ViewResponseDataFromJson(json);
}

