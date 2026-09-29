// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_reply_comment_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateReplyCommentDto _$CreateReplyCommentDtoFromJson(
    Map<String, dynamic> json) {
  return _CreateReplyCommentDto.fromJson(json);
}

/// @nodoc
mixin _$CreateReplyCommentDto {
  String get parentComment => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateReplyCommentDtoCopyWith<CreateReplyCommentDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateReplyCommentDtoCopyWith<$Res> {
  factory $CreateReplyCommentDtoCopyWith(CreateReplyCommentDto value,
          $Res Function(CreateReplyCommentDto) then) =
      _$CreateReplyCommentDtoCopyWithImpl<$Res, CreateReplyCommentDto>;
  @useResult
  $Res call({String parentComment, String content});
}

/// @nodoc
class _$CreateReplyCommentDtoCopyWithImpl<$Res,
        $Val extends CreateReplyCommentDto>
    implements $CreateReplyCommentDtoCopyWith<$Res> {
  _$CreateReplyCommentDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentComment = null,
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      parentComment: null == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateReplyCommentDtoImplCopyWith<$Res>
    implements $CreateReplyCommentDtoCopyWith<$Res> {
  factory _$$CreateReplyCommentDtoImplCopyWith(
          _$CreateReplyCommentDtoImpl value,
          $Res Function(_$CreateReplyCommentDtoImpl) then) =
      __$$CreateReplyCommentDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String parentComment, String content});
}

/// @nodoc
class __$$CreateReplyCommentDtoImplCopyWithImpl<$Res>
    extends _$CreateReplyCommentDtoCopyWithImpl<$Res,
        _$CreateReplyCommentDtoImpl>
    implements _$$CreateReplyCommentDtoImplCopyWith<$Res> {
  __$$CreateReplyCommentDtoImplCopyWithImpl(_$CreateReplyCommentDtoImpl _value,
      $Res Function(_$CreateReplyCommentDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentComment = null,
    Object? content = null,
  }) {
    return _then(_$CreateReplyCommentDtoImpl(
      parentComment: null == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateReplyCommentDtoImpl implements _CreateReplyCommentDto {
  const _$CreateReplyCommentDtoImpl(
      {required this.parentComment, required this.content});

  factory _$CreateReplyCommentDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateReplyCommentDtoImplFromJson(json);

  @override
  final String parentComment;
  @override
  final String content;

  @override
  String toString() {
    return 'CreateReplyCommentDto(parentComment: $parentComment, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateReplyCommentDtoImpl &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, parentComment, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateReplyCommentDtoImplCopyWith<_$CreateReplyCommentDtoImpl>
      get copyWith => __$$CreateReplyCommentDtoImplCopyWithImpl<
          _$CreateReplyCommentDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateReplyCommentDtoImplToJson(
      this,
    );
  }
}

abstract class _CreateReplyCommentDto implements CreateReplyCommentDto {
  const factory _CreateReplyCommentDto(
      {required final String parentComment,
      required final String content}) = _$CreateReplyCommentDtoImpl;

  factory _CreateReplyCommentDto.fromJson(Map<String, dynamic> json) =
      _$CreateReplyCommentDtoImpl.fromJson;

  @override
  String get parentComment;
  @override
  String get content;
  @override
  @JsonKey(ignore: true)
  _$$CreateReplyCommentDtoImplCopyWith<_$CreateReplyCommentDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
