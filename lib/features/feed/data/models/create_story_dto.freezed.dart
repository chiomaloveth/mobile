// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_story_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateStoryDto _$CreateStoryDtoFromJson(Map<String, dynamic> json) {
  return _CreateStoryDto.fromJson(json);
}

/// @nodoc
mixin _$CreateStoryDto {
  List<String>? get media => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  String? get overlayText => throw _privateConstructorUsedError;
  List<String>? get overlayVideos => throw _privateConstructorUsedError;
  PostMusic? get music => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreateStoryDtoCopyWith<CreateStoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateStoryDtoCopyWith<$Res> {
  factory $CreateStoryDtoCopyWith(
          CreateStoryDto value, $Res Function(CreateStoryDto) then) =
      _$CreateStoryDtoCopyWithImpl<$Res, CreateStoryDto>;
  @useResult
  $Res call(
      {List<String>? media,
      String? caption,
      String? overlayText,
      List<String>? overlayVideos,
      PostMusic? music});

  $PostMusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$CreateStoryDtoCopyWithImpl<$Res, $Val extends CreateStoryDto>
    implements $CreateStoryDtoCopyWith<$Res> {
  _$CreateStoryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = freezed,
    Object? caption = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? music = freezed,
  }) {
    return _then(_value.copyWith(
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as PostMusic?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PostMusicCopyWith<$Res>? get music {
    if (_value.music == null) {
      return null;
    }

    return $PostMusicCopyWith<$Res>(_value.music!, (value) {
      return _then(_value.copyWith(music: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateStoryDtoImplCopyWith<$Res>
    implements $CreateStoryDtoCopyWith<$Res> {
  factory _$$CreateStoryDtoImplCopyWith(_$CreateStoryDtoImpl value,
          $Res Function(_$CreateStoryDtoImpl) then) =
      __$$CreateStoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String>? media,
      String? caption,
      String? overlayText,
      List<String>? overlayVideos,
      PostMusic? music});

  @override
  $PostMusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$CreateStoryDtoImplCopyWithImpl<$Res>
    extends _$CreateStoryDtoCopyWithImpl<$Res, _$CreateStoryDtoImpl>
    implements _$$CreateStoryDtoImplCopyWith<$Res> {
  __$$CreateStoryDtoImplCopyWithImpl(
      _$CreateStoryDtoImpl _value, $Res Function(_$CreateStoryDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? media = freezed,
    Object? caption = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? music = freezed,
  }) {
    return _then(_$CreateStoryDtoImpl(
      media: freezed == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as PostMusic?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateStoryDtoImpl implements _CreateStoryDto {
  const _$CreateStoryDtoImpl(
      {final List<String>? media,
      this.caption,
      this.overlayText,
      final List<String>? overlayVideos,
      this.music})
      : _media = media,
        _overlayVideos = overlayVideos;

  factory _$CreateStoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateStoryDtoImplFromJson(json);

  final List<String>? _media;
  @override
  List<String>? get media {
    final value = _media;
    if (value == null) return null;
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? caption;
  @override
  final String? overlayText;
  final List<String>? _overlayVideos;
  @override
  List<String>? get overlayVideos {
    final value = _overlayVideos;
    if (value == null) return null;
    if (_overlayVideos is EqualUnmodifiableListView) return _overlayVideos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final PostMusic? music;

  @override
  String toString() {
    return 'CreateStoryDto(media: $media, caption: $caption, overlayText: $overlayText, overlayVideos: $overlayVideos, music: $music)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateStoryDtoImpl &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos) &&
            (identical(other.music, music) || other.music == music));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_media),
      caption,
      overlayText,
      const DeepCollectionEquality().hash(_overlayVideos),
      music);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateStoryDtoImplCopyWith<_$CreateStoryDtoImpl> get copyWith =>
      __$$CreateStoryDtoImplCopyWithImpl<_$CreateStoryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateStoryDtoImplToJson(
      this,
    );
  }
}

abstract class _CreateStoryDto implements CreateStoryDto {
  const factory _CreateStoryDto(
      {final List<String>? media,
      final String? caption,
      final String? overlayText,
      final List<String>? overlayVideos,
      final PostMusic? music}) = _$CreateStoryDtoImpl;

  factory _CreateStoryDto.fromJson(Map<String, dynamic> json) =
      _$CreateStoryDtoImpl.fromJson;

  @override
  List<String>? get media;
  @override
  String? get caption;
  @override
  String? get overlayText;
  @override
  List<String>? get overlayVideos;
  @override
  PostMusic? get music;
  @override
  @JsonKey(ignore: true)
  _$$CreateStoryDtoImplCopyWith<_$CreateStoryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
