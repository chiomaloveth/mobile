// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_mark_response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookMarkResponseDataImpl _$$BookMarkResponseDataImplFromJson(
        Map<String, dynamic> json) =>
    _$BookMarkResponseDataImpl(
      success: json['success'] as bool,
      bookmarked: json['bookmarked'] as bool,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$BookMarkResponseDataImplToJson(
        _$BookMarkResponseDataImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'bookmarked': instance.bookmarked,
      'message': instance.message,
    };
