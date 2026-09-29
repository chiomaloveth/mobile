// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_mark_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookMarkResponseData _$BookMarkResponseDataFromJson(Map<String, dynamic> json) {
  return _BookMarkResponseData.fromJson(json);
}

/// @nodoc
mixin _$BookMarkResponseData {
  bool get success => throw _privateConstructorUsedError;
  bool get bookmarked => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookMarkResponseDataCopyWith<BookMarkResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookMarkResponseDataCopyWith<$Res> {
  factory $BookMarkResponseDataCopyWith(BookMarkResponseData value,
          $Res Function(BookMarkResponseData) then) =
      _$BookMarkResponseDataCopyWithImpl<$Res, BookMarkResponseData>;
  @useResult
  $Res call({bool success, bool bookmarked, String message});
}

/// @nodoc
class _$BookMarkResponseDataCopyWithImpl<$Res,
        $Val extends BookMarkResponseData>
    implements $BookMarkResponseDataCopyWith<$Res> {
  _$BookMarkResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? bookmarked = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      bookmarked: null == bookmarked
          ? _value.bookmarked
          : bookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookMarkResponseDataImplCopyWith<$Res>
    implements $BookMarkResponseDataCopyWith<$Res> {
  factory _$$BookMarkResponseDataImplCopyWith(_$BookMarkResponseDataImpl value,
          $Res Function(_$BookMarkResponseDataImpl) then) =
      __$$BookMarkResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, bool bookmarked, String message});
}

/// @nodoc
class __$$BookMarkResponseDataImplCopyWithImpl<$Res>
    extends _$BookMarkResponseDataCopyWithImpl<$Res, _$BookMarkResponseDataImpl>
    implements _$$BookMarkResponseDataImplCopyWith<$Res> {
  __$$BookMarkResponseDataImplCopyWithImpl(_$BookMarkResponseDataImpl _value,
      $Res Function(_$BookMarkResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? bookmarked = null,
    Object? message = null,
  }) {
    return _then(_$BookMarkResponseDataImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      bookmarked: null == bookmarked
          ? _value.bookmarked
          : bookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookMarkResponseDataImpl implements _BookMarkResponseData {
  const _$BookMarkResponseDataImpl(
      {required this.success, required this.bookmarked, required this.message});

  factory _$BookMarkResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookMarkResponseDataImplFromJson(json);

  @override
  final bool success;
  @override
  final bool bookmarked;
  @override
  final String message;

  @override
  String toString() {
    return 'BookMarkResponseData(success: $success, bookmarked: $bookmarked, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookMarkResponseDataImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.bookmarked, bookmarked) ||
                other.bookmarked == bookmarked) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, bookmarked, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookMarkResponseDataImplCopyWith<_$BookMarkResponseDataImpl>
      get copyWith =>
          __$$BookMarkResponseDataImplCopyWithImpl<_$BookMarkResponseDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookMarkResponseDataImplToJson(
      this,
    );
  }
}

abstract class _BookMarkResponseData implements BookMarkResponseData {
  const factory _BookMarkResponseData(
      {required final bool success,
      required final bool bookmarked,
      required final String message}) = _$BookMarkResponseDataImpl;

  factory _BookMarkResponseData.fromJson(Map<String, dynamic> json) =
      _$BookMarkResponseDataImpl.fromJson;

  @override
  bool get success;
  @override
  bool get bookmarked;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$BookMarkResponseDataImplCopyWith<_$BookMarkResponseDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
