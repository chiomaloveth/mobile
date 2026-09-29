// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_search_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MusicSearchResponse _$MusicSearchResponseFromJson(Map<String, dynamic> json) {
  return _MusicSearchResponse.fromJson(json);
}

/// @nodoc
mixin _$MusicSearchResponse {
  bool get success => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  List<MusicData> get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MusicSearchResponseCopyWith<MusicSearchResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MusicSearchResponseCopyWith<$Res> {
  factory $MusicSearchResponseCopyWith(
          MusicSearchResponse value, $Res Function(MusicSearchResponse) then) =
      _$MusicSearchResponseCopyWithImpl<$Res, MusicSearchResponse>;
  @useResult
  $Res call({bool success, int count, List<MusicData> data});
}

/// @nodoc
class _$MusicSearchResponseCopyWithImpl<$Res, $Val extends MusicSearchResponse>
    implements $MusicSearchResponseCopyWith<$Res> {
  _$MusicSearchResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<MusicData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MusicSearchResponseImplCopyWith<$Res>
    implements $MusicSearchResponseCopyWith<$Res> {
  factory _$$MusicSearchResponseImplCopyWith(_$MusicSearchResponseImpl value,
          $Res Function(_$MusicSearchResponseImpl) then) =
      __$$MusicSearchResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, int count, List<MusicData> data});
}

/// @nodoc
class __$$MusicSearchResponseImplCopyWithImpl<$Res>
    extends _$MusicSearchResponseCopyWithImpl<$Res, _$MusicSearchResponseImpl>
    implements _$$MusicSearchResponseImplCopyWith<$Res> {
  __$$MusicSearchResponseImplCopyWithImpl(_$MusicSearchResponseImpl _value,
      $Res Function(_$MusicSearchResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? count = null,
    Object? data = null,
  }) {
    return _then(_$MusicSearchResponseImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<MusicData>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MusicSearchResponseImpl implements _MusicSearchResponse {
  const _$MusicSearchResponseImpl(
      {required this.success,
      required this.count,
      required final List<MusicData> data})
      : _data = data;

  factory _$MusicSearchResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$MusicSearchResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final int count;
  final List<MusicData> _data;
  @override
  List<MusicData> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'MusicSearchResponse(success: $success, count: $count, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MusicSearchResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.count, count) || other.count == count) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, success, count, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MusicSearchResponseImplCopyWith<_$MusicSearchResponseImpl> get copyWith =>
      __$$MusicSearchResponseImplCopyWithImpl<_$MusicSearchResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MusicSearchResponseImplToJson(
      this,
    );
  }
}

abstract class _MusicSearchResponse implements MusicSearchResponse {
  const factory _MusicSearchResponse(
      {required final bool success,
      required final int count,
      required final List<MusicData> data}) = _$MusicSearchResponseImpl;

  factory _MusicSearchResponse.fromJson(Map<String, dynamic> json) =
      _$MusicSearchResponseImpl.fromJson;

  @override
  bool get success;
  @override
  int get count;
  @override
  List<MusicData> get data;
  @override
  @JsonKey(ignore: true)
  _$$MusicSearchResponseImplCopyWith<_$MusicSearchResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MusicData _$MusicDataFromJson(Map<String, dynamic> json) {
  return _MusicData.fromJson(json);
}

/// @nodoc
mixin _$MusicData {
  String get thirdPartyId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MusicDataCopyWith<MusicData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MusicDataCopyWith<$Res> {
  factory $MusicDataCopyWith(MusicData value, $Res Function(MusicData) then) =
      _$MusicDataCopyWithImpl<$Res, MusicData>;
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String? coverImage,
      String audioUrl});
}

/// @nodoc
class _$MusicDataCopyWithImpl<$Res, $Val extends MusicData>
    implements $MusicDataCopyWith<$Res> {
  _$MusicDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thirdPartyId = null,
    Object? title = null,
    Object? artist = null,
    Object? coverImage = freezed,
    Object? audioUrl = null,
  }) {
    return _then(_value.copyWith(
      thirdPartyId: null == thirdPartyId
          ? _value.thirdPartyId
          : thirdPartyId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MusicDataImplCopyWith<$Res>
    implements $MusicDataCopyWith<$Res> {
  factory _$$MusicDataImplCopyWith(
          _$MusicDataImpl value, $Res Function(_$MusicDataImpl) then) =
      __$$MusicDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String? coverImage,
      String audioUrl});
}

/// @nodoc
class __$$MusicDataImplCopyWithImpl<$Res>
    extends _$MusicDataCopyWithImpl<$Res, _$MusicDataImpl>
    implements _$$MusicDataImplCopyWith<$Res> {
  __$$MusicDataImplCopyWithImpl(
      _$MusicDataImpl _value, $Res Function(_$MusicDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thirdPartyId = null,
    Object? title = null,
    Object? artist = null,
    Object? coverImage = freezed,
    Object? audioUrl = null,
  }) {
    return _then(_$MusicDataImpl(
      thirdPartyId: null == thirdPartyId
          ? _value.thirdPartyId
          : thirdPartyId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MusicDataImpl implements _MusicData {
  const _$MusicDataImpl(
      {required this.thirdPartyId,
      required this.title,
      required this.artist,
      this.coverImage,
      required this.audioUrl});

  factory _$MusicDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$MusicDataImplFromJson(json);

  @override
  final String thirdPartyId;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String? coverImage;
  @override
  final String audioUrl;

  @override
  String toString() {
    return 'MusicData(thirdPartyId: $thirdPartyId, title: $title, artist: $artist, coverImage: $coverImage, audioUrl: $audioUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MusicDataImpl &&
            (identical(other.thirdPartyId, thirdPartyId) ||
                other.thirdPartyId == thirdPartyId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, thirdPartyId, title, artist, coverImage, audioUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MusicDataImplCopyWith<_$MusicDataImpl> get copyWith =>
      __$$MusicDataImplCopyWithImpl<_$MusicDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MusicDataImplToJson(
      this,
    );
  }
}

abstract class _MusicData implements MusicData {
  const factory _MusicData(
      {required final String thirdPartyId,
      required final String title,
      required final String artist,
      final String? coverImage,
      required final String audioUrl}) = _$MusicDataImpl;

  factory _MusicData.fromJson(Map<String, dynamic> json) =
      _$MusicDataImpl.fromJson;

  @override
  String get thirdPartyId;
  @override
  String get title;
  @override
  String get artist;
  @override
  String? get coverImage;
  @override
  String get audioUrl;
  @override
  @JsonKey(ignore: true)
  _$$MusicDataImplCopyWith<_$MusicDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
