// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_preference_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GetPreferenceList _$GetPreferenceListFromJson(Map<String, dynamic> json) {
  return _GetPreferenceList.fromJson(json);
}

/// @nodoc
mixin _$GetPreferenceList {
  bool get success => throw _privateConstructorUsedError;
  CategoriesData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $GetPreferenceListCopyWith<GetPreferenceList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GetPreferenceListCopyWith<$Res> {
  factory $GetPreferenceListCopyWith(
          GetPreferenceList value, $Res Function(GetPreferenceList) then) =
      _$GetPreferenceListCopyWithImpl<$Res, GetPreferenceList>;
  @useResult
  $Res call({bool success, CategoriesData? data});

  $CategoriesDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$GetPreferenceListCopyWithImpl<$Res, $Val extends GetPreferenceList>
    implements $GetPreferenceListCopyWith<$Res> {
  _$GetPreferenceListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CategoriesData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoriesDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CategoriesDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GetPreferenceListImplCopyWith<$Res>
    implements $GetPreferenceListCopyWith<$Res> {
  factory _$$GetPreferenceListImplCopyWith(_$GetPreferenceListImpl value,
          $Res Function(_$GetPreferenceListImpl) then) =
      __$$GetPreferenceListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, CategoriesData? data});

  @override
  $CategoriesDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$GetPreferenceListImplCopyWithImpl<$Res>
    extends _$GetPreferenceListCopyWithImpl<$Res, _$GetPreferenceListImpl>
    implements _$$GetPreferenceListImplCopyWith<$Res> {
  __$$GetPreferenceListImplCopyWithImpl(_$GetPreferenceListImpl _value,
      $Res Function(_$GetPreferenceListImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? data = freezed,
  }) {
    return _then(_$GetPreferenceListImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as CategoriesData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GetPreferenceListImpl implements _GetPreferenceList {
  const _$GetPreferenceListImpl({required this.success, this.data});

  factory _$GetPreferenceListImpl.fromJson(Map<String, dynamic> json) =>
      _$$GetPreferenceListImplFromJson(json);

  @override
  final bool success;
  @override
  final CategoriesData? data;

  @override
  String toString() {
    return 'GetPreferenceList(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetPreferenceListImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GetPreferenceListImplCopyWith<_$GetPreferenceListImpl> get copyWith =>
      __$$GetPreferenceListImplCopyWithImpl<_$GetPreferenceListImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GetPreferenceListImplToJson(
      this,
    );
  }
}

abstract class _GetPreferenceList implements GetPreferenceList {
  const factory _GetPreferenceList(
      {required final bool success,
      final CategoriesData? data}) = _$GetPreferenceListImpl;

  factory _GetPreferenceList.fromJson(Map<String, dynamic> json) =
      _$GetPreferenceListImpl.fromJson;

  @override
  bool get success;
  @override
  CategoriesData? get data;
  @override
  @JsonKey(ignore: true)
  _$$GetPreferenceListImplCopyWith<_$GetPreferenceListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoriesData _$CategoriesDataFromJson(Map<String, dynamic> json) {
  return _CategoriesData.fromJson(json);
}

/// @nodoc
mixin _$CategoriesData {
  List<String>? get entertainment => throw _privateConstructorUsedError;
  List<String>? get homeFamily => throw _privateConstructorUsedError;
  List<String>? get fashionBeauty => throw _privateConstructorUsedError;
  bool? get isPreferenceSet => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CategoriesDataCopyWith<CategoriesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoriesDataCopyWith<$Res> {
  factory $CategoriesDataCopyWith(
          CategoriesData value, $Res Function(CategoriesData) then) =
      _$CategoriesDataCopyWithImpl<$Res, CategoriesData>;
  @useResult
  $Res call(
      {List<String>? entertainment,
      List<String>? homeFamily,
      List<String>? fashionBeauty,
      bool? isPreferenceSet});
}

/// @nodoc
class _$CategoriesDataCopyWithImpl<$Res, $Val extends CategoriesData>
    implements $CategoriesDataCopyWith<$Res> {
  _$CategoriesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = freezed,
    Object? homeFamily = freezed,
    Object? fashionBeauty = freezed,
    Object? isPreferenceSet = freezed,
  }) {
    return _then(_value.copyWith(
      entertainment: freezed == entertainment
          ? _value.entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      homeFamily: freezed == homeFamily
          ? _value.homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      fashionBeauty: freezed == fashionBeauty
          ? _value.fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isPreferenceSet: freezed == isPreferenceSet
          ? _value.isPreferenceSet
          : isPreferenceSet // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoriesDataImplCopyWith<$Res>
    implements $CategoriesDataCopyWith<$Res> {
  factory _$$CategoriesDataImplCopyWith(_$CategoriesDataImpl value,
          $Res Function(_$CategoriesDataImpl) then) =
      __$$CategoriesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? entertainment,
      List<String>? homeFamily,
      List<String>? fashionBeauty,
      bool? isPreferenceSet});
}

/// @nodoc
class __$$CategoriesDataImplCopyWithImpl<$Res>
    extends _$CategoriesDataCopyWithImpl<$Res, _$CategoriesDataImpl>
    implements _$$CategoriesDataImplCopyWith<$Res> {
  __$$CategoriesDataImplCopyWithImpl(
      _$CategoriesDataImpl _value, $Res Function(_$CategoriesDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entertainment = freezed,
    Object? homeFamily = freezed,
    Object? fashionBeauty = freezed,
    Object? isPreferenceSet = freezed,
  }) {
    return _then(_$CategoriesDataImpl(
      entertainment: freezed == entertainment
          ? _value._entertainment
          : entertainment // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      homeFamily: freezed == homeFamily
          ? _value._homeFamily
          : homeFamily // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      fashionBeauty: freezed == fashionBeauty
          ? _value._fashionBeauty
          : fashionBeauty // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isPreferenceSet: freezed == isPreferenceSet
          ? _value.isPreferenceSet
          : isPreferenceSet // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoriesDataImpl implements _CategoriesData {
  const _$CategoriesDataImpl(
      {final List<String>? entertainment,
      final List<String>? homeFamily,
      final List<String>? fashionBeauty,
      this.isPreferenceSet = false})
      : _entertainment = entertainment,
        _homeFamily = homeFamily,
        _fashionBeauty = fashionBeauty;

  factory _$CategoriesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoriesDataImplFromJson(json);

  final List<String>? _entertainment;
  @override
  List<String>? get entertainment {
    final value = _entertainment;
    if (value == null) return null;
    if (_entertainment is EqualUnmodifiableListView) return _entertainment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _homeFamily;
  @override
  List<String>? get homeFamily {
    final value = _homeFamily;
    if (value == null) return null;
    if (_homeFamily is EqualUnmodifiableListView) return _homeFamily;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _fashionBeauty;
  @override
  List<String>? get fashionBeauty {
    final value = _fashionBeauty;
    if (value == null) return null;
    if (_fashionBeauty is EqualUnmodifiableListView) return _fashionBeauty;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool? isPreferenceSet;

  @override
  String toString() {
    return 'CategoriesData(entertainment: $entertainment, homeFamily: $homeFamily, fashionBeauty: $fashionBeauty, isPreferenceSet: $isPreferenceSet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoriesDataImpl &&
            const DeepCollectionEquality()
                .equals(other._entertainment, _entertainment) &&
            const DeepCollectionEquality()
                .equals(other._homeFamily, _homeFamily) &&
            const DeepCollectionEquality()
                .equals(other._fashionBeauty, _fashionBeauty) &&
            (identical(other.isPreferenceSet, isPreferenceSet) ||
                other.isPreferenceSet == isPreferenceSet));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_entertainment),
      const DeepCollectionEquality().hash(_homeFamily),
      const DeepCollectionEquality().hash(_fashionBeauty),
      isPreferenceSet);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoriesDataImplCopyWith<_$CategoriesDataImpl> get copyWith =>
      __$$CategoriesDataImplCopyWithImpl<_$CategoriesDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoriesDataImplToJson(
      this,
    );
  }
}

abstract class _CategoriesData implements CategoriesData {
  const factory _CategoriesData(
      {final List<String>? entertainment,
      final List<String>? homeFamily,
      final List<String>? fashionBeauty,
      final bool? isPreferenceSet}) = _$CategoriesDataImpl;

  factory _CategoriesData.fromJson(Map<String, dynamic> json) =
      _$CategoriesDataImpl.fromJson;

  @override
  List<String>? get entertainment;
  @override
  List<String>? get homeFamily;
  @override
  List<String>? get fashionBeauty;
  @override
  bool? get isPreferenceSet;
  @override
  @JsonKey(ignore: true)
  _$$CategoriesDataImplCopyWith<_$CategoriesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
