// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delete_comment_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeleteCommentResponseData _$DeleteCommentResponseDataFromJson(
    Map<String, dynamic> json) {
  return _DeleteCommentResponseData.fromJson(json);
}

/// @nodoc
mixin _$DeleteCommentResponseData {
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeleteCommentResponseDataCopyWith<DeleteCommentResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeleteCommentResponseDataCopyWith<$Res> {
  factory $DeleteCommentResponseDataCopyWith(DeleteCommentResponseData value,
          $Res Function(DeleteCommentResponseData) then) =
      _$DeleteCommentResponseDataCopyWithImpl<$Res, DeleteCommentResponseData>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$DeleteCommentResponseDataCopyWithImpl<$Res,
        $Val extends DeleteCommentResponseData>
    implements $DeleteCommentResponseDataCopyWith<$Res> {
  _$DeleteCommentResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeleteCommentResponseDataImplCopyWith<$Res>
    implements $DeleteCommentResponseDataCopyWith<$Res> {
  factory _$$DeleteCommentResponseDataImplCopyWith(
          _$DeleteCommentResponseDataImpl value,
          $Res Function(_$DeleteCommentResponseDataImpl) then) =
      __$$DeleteCommentResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DeleteCommentResponseDataImplCopyWithImpl<$Res>
    extends _$DeleteCommentResponseDataCopyWithImpl<$Res,
        _$DeleteCommentResponseDataImpl>
    implements _$$DeleteCommentResponseDataImplCopyWith<$Res> {
  __$$DeleteCommentResponseDataImplCopyWithImpl(
      _$DeleteCommentResponseDataImpl _value,
      $Res Function(_$DeleteCommentResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$DeleteCommentResponseDataImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeleteCommentResponseDataImpl implements _DeleteCommentResponseData {
  const _$DeleteCommentResponseDataImpl({required this.message});

  factory _$DeleteCommentResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeleteCommentResponseDataImplFromJson(json);

  @override
  final String message;

  @override
  String toString() {
    return 'DeleteCommentResponseData(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeleteCommentResponseDataImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeleteCommentResponseDataImplCopyWith<_$DeleteCommentResponseDataImpl>
      get copyWith => __$$DeleteCommentResponseDataImplCopyWithImpl<
          _$DeleteCommentResponseDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeleteCommentResponseDataImplToJson(
      this,
    );
  }
}

abstract class _DeleteCommentResponseData implements DeleteCommentResponseData {
  const factory _DeleteCommentResponseData({required final String message}) =
      _$DeleteCommentResponseDataImpl;

  factory _DeleteCommentResponseData.fromJson(Map<String, dynamic> json) =
      _$DeleteCommentResponseDataImpl.fromJson;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$DeleteCommentResponseDataImplCopyWith<_$DeleteCommentResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
