// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_response_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ViewResponseData _$ViewResponseDataFromJson(Map<String, dynamic> json) {
  return _ViewResponseData.fromJson(json);
}

/// @nodoc
mixin _$ViewResponseData {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ViewResponseDataCopyWith<ViewResponseData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ViewResponseDataCopyWith<$Res> {
  factory $ViewResponseDataCopyWith(
          ViewResponseData value, $Res Function(ViewResponseData) then) =
      _$ViewResponseDataCopyWithImpl<$Res, ViewResponseData>;
  @useResult
  $Res call({bool success, String message});
}

/// @nodoc
class _$ViewResponseDataCopyWithImpl<$Res, $Val extends ViewResponseData>
    implements $ViewResponseDataCopyWith<$Res> {
  _$ViewResponseDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ViewResponseDataImplCopyWith<$Res>
    implements $ViewResponseDataCopyWith<$Res> {
  factory _$$ViewResponseDataImplCopyWith(_$ViewResponseDataImpl value,
          $Res Function(_$ViewResponseDataImpl) then) =
      __$$ViewResponseDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message});
}

/// @nodoc
class __$$ViewResponseDataImplCopyWithImpl<$Res>
    extends _$ViewResponseDataCopyWithImpl<$Res, _$ViewResponseDataImpl>
    implements _$$ViewResponseDataImplCopyWith<$Res> {
  __$$ViewResponseDataImplCopyWithImpl(_$ViewResponseDataImpl _value,
      $Res Function(_$ViewResponseDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
  }) {
    return _then(_$ViewResponseDataImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
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
class _$ViewResponseDataImpl implements _ViewResponseData {
  const _$ViewResponseDataImpl({required this.success, required this.message});

  factory _$ViewResponseDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ViewResponseDataImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;

  @override
  String toString() {
    return 'ViewResponseData(success: $success, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ViewResponseDataImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ViewResponseDataImplCopyWith<_$ViewResponseDataImpl> get copyWith =>
      __$$ViewResponseDataImplCopyWithImpl<_$ViewResponseDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ViewResponseDataImplToJson(
      this,
    );
  }
}

abstract class _ViewResponseData implements ViewResponseData {
  const factory _ViewResponseData(
      {required final bool success,
      required final String message}) = _$ViewResponseDataImpl;

  factory _ViewResponseData.fromJson(Map<String, dynamic> json) =
      _$ViewResponseDataImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$ViewResponseDataImplCopyWith<_$ViewResponseDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
