// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreatePostDto _$CreatePostDtoFromJson(Map<String, dynamic> json) {
  return _CreatePostDto.fromJson(json);
}

/// @nodoc
mixin _$CreatePostDto {
  String? get content => throw _privateConstructorUsedError;
  List<String>? get media => throw _privateConstructorUsedError;
  PostMusic? get music => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  String? get overlayText => throw _privateConstructorUsedError;
  List<String>? get overlayVideos => throw _privateConstructorUsedError;
  @JsonKey(name: 'allowComment')
  bool? get allowComment => throw _privateConstructorUsedError;
  List<String>? get taggedUsers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CreatePostDtoCopyWith<CreatePostDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatePostDtoCopyWith<$Res> {
  factory $CreatePostDtoCopyWith(
          CreatePostDto value, $Res Function(CreatePostDto) then) =
      _$CreatePostDtoCopyWithImpl<$Res, CreatePostDto>;
  @useResult
  $Res call(
      {String? content,
      List<String>? media,
      PostMusic? music,
      List<String>? tags,
      String? overlayText,
      List<String>? overlayVideos,
      @JsonKey(name: 'allowComment') bool? allowComment,
      List<String>? taggedUsers});

  $PostMusicCopyWith<$Res>? get music;
}

/// @nodoc
class _$CreatePostDtoCopyWithImpl<$Res, $Val extends CreatePostDto>
    implements $CreatePostDtoCopyWith<$Res> {
  _$CreatePostDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = freezed,
    Object? media = freezed,
    Object? music = freezed,
    Object? tags = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? allowComment = freezed,
    Object? taggedUsers = freezed,
  }) {
    return _then(_value.copyWith(
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as PostMusic?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value.overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allowComment: freezed == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool?,
      taggedUsers: freezed == taggedUsers
          ? _value.taggedUsers
          : taggedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
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
abstract class _$$CreatePostDtoImplCopyWith<$Res>
    implements $CreatePostDtoCopyWith<$Res> {
  factory _$$CreatePostDtoImplCopyWith(
          _$CreatePostDtoImpl value, $Res Function(_$CreatePostDtoImpl) then) =
      __$$CreatePostDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? content,
      List<String>? media,
      PostMusic? music,
      List<String>? tags,
      String? overlayText,
      List<String>? overlayVideos,
      @JsonKey(name: 'allowComment') bool? allowComment,
      List<String>? taggedUsers});

  @override
  $PostMusicCopyWith<$Res>? get music;
}

/// @nodoc
class __$$CreatePostDtoImplCopyWithImpl<$Res>
    extends _$CreatePostDtoCopyWithImpl<$Res, _$CreatePostDtoImpl>
    implements _$$CreatePostDtoImplCopyWith<$Res> {
  __$$CreatePostDtoImplCopyWithImpl(
      _$CreatePostDtoImpl _value, $Res Function(_$CreatePostDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = freezed,
    Object? media = freezed,
    Object? music = freezed,
    Object? tags = freezed,
    Object? overlayText = freezed,
    Object? overlayVideos = freezed,
    Object? allowComment = freezed,
    Object? taggedUsers = freezed,
  }) {
    return _then(_$CreatePostDtoImpl(
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      media: freezed == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      music: freezed == music
          ? _value.music
          : music // ignore: cast_nullable_to_non_nullable
              as PostMusic?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      overlayText: freezed == overlayText
          ? _value.overlayText
          : overlayText // ignore: cast_nullable_to_non_nullable
              as String?,
      overlayVideos: freezed == overlayVideos
          ? _value._overlayVideos
          : overlayVideos // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      allowComment: freezed == allowComment
          ? _value.allowComment
          : allowComment // ignore: cast_nullable_to_non_nullable
              as bool?,
      taggedUsers: freezed == taggedUsers
          ? _value._taggedUsers
          : taggedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatePostDtoImpl implements _CreatePostDto {
  const _$CreatePostDtoImpl(
      {this.content,
      final List<String>? media,
      this.music,
      final List<String>? tags,
      this.overlayText,
      final List<String>? overlayVideos,
      @JsonKey(name: 'allowComment') this.allowComment,
      final List<String>? taggedUsers})
      : _media = media,
        _tags = tags,
        _overlayVideos = overlayVideos,
        _taggedUsers = taggedUsers;

  factory _$CreatePostDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatePostDtoImplFromJson(json);

  @override
  final String? content;
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
  final PostMusic? music;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
  @JsonKey(name: 'allowComment')
  final bool? allowComment;
  final List<String>? _taggedUsers;
  @override
  List<String>? get taggedUsers {
    final value = _taggedUsers;
    if (value == null) return null;
    if (_taggedUsers is EqualUnmodifiableListView) return _taggedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'CreatePostDto(content: $content, media: $media, music: $music, tags: $tags, overlayText: $overlayText, overlayVideos: $overlayVideos, allowComment: $allowComment, taggedUsers: $taggedUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatePostDtoImpl &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            (identical(other.music, music) || other.music == music) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.overlayText, overlayText) ||
                other.overlayText == overlayText) &&
            const DeepCollectionEquality()
                .equals(other._overlayVideos, _overlayVideos) &&
            (identical(other.allowComment, allowComment) ||
                other.allowComment == allowComment) &&
            const DeepCollectionEquality()
                .equals(other._taggedUsers, _taggedUsers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      content,
      const DeepCollectionEquality().hash(_media),
      music,
      const DeepCollectionEquality().hash(_tags),
      overlayText,
      const DeepCollectionEquality().hash(_overlayVideos),
      allowComment,
      const DeepCollectionEquality().hash(_taggedUsers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatePostDtoImplCopyWith<_$CreatePostDtoImpl> get copyWith =>
      __$$CreatePostDtoImplCopyWithImpl<_$CreatePostDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatePostDtoImplToJson(
      this,
    );
  }
}

abstract class _CreatePostDto implements CreatePostDto {
  const factory _CreatePostDto(
      {final String? content,
      final List<String>? media,
      final PostMusic? music,
      final List<String>? tags,
      final String? overlayText,
      final List<String>? overlayVideos,
      @JsonKey(name: 'allowComment') final bool? allowComment,
      final List<String>? taggedUsers}) = _$CreatePostDtoImpl;

  factory _CreatePostDto.fromJson(Map<String, dynamic> json) =
      _$CreatePostDtoImpl.fromJson;

  @override
  String? get content;
  @override
  List<String>? get media;
  @override
  PostMusic? get music;
  @override
  List<String>? get tags;
  @override
  String? get overlayText;
  @override
  List<String>? get overlayVideos;
  @override
  @JsonKey(name: 'allowComment')
  bool? get allowComment;
  @override
  List<String>? get taggedUsers;
  @override
  @JsonKey(ignore: true)
  _$$CreatePostDtoImplCopyWith<_$CreatePostDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PostMusic _$PostMusicFromJson(Map<String, dynamic> json) {
  return _PostMusic.fromJson(json);
}

/// @nodoc
mixin _$PostMusic {
  String get thirdPartyId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostMusicCopyWith<PostMusic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostMusicCopyWith<$Res> {
  factory $PostMusicCopyWith(PostMusic value, $Res Function(PostMusic) then) =
      _$PostMusicCopyWithImpl<$Res, PostMusic>;
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String audioUrl,
      String? coverImage});
}

/// @nodoc
class _$PostMusicCopyWithImpl<$Res, $Val extends PostMusic>
    implements $PostMusicCopyWith<$Res> {
  _$PostMusicCopyWithImpl(this._value, this._then);

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
    Object? audioUrl = null,
    Object? coverImage = freezed,
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
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostMusicImplCopyWith<$Res>
    implements $PostMusicCopyWith<$Res> {
  factory _$$PostMusicImplCopyWith(
          _$PostMusicImpl value, $Res Function(_$PostMusicImpl) then) =
      __$$PostMusicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String thirdPartyId,
      String title,
      String artist,
      String audioUrl,
      String? coverImage});
}

/// @nodoc
class __$$PostMusicImplCopyWithImpl<$Res>
    extends _$PostMusicCopyWithImpl<$Res, _$PostMusicImpl>
    implements _$$PostMusicImplCopyWith<$Res> {
  __$$PostMusicImplCopyWithImpl(
      _$PostMusicImpl _value, $Res Function(_$PostMusicImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? thirdPartyId = null,
    Object? title = null,
    Object? artist = null,
    Object? audioUrl = null,
    Object? coverImage = freezed,
  }) {
    return _then(_$PostMusicImpl(
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
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _value.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostMusicImpl implements _PostMusic {
  const _$PostMusicImpl(
      {required this.thirdPartyId,
      required this.title,
      required this.artist,
      required this.audioUrl,
      this.coverImage});

  factory _$PostMusicImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostMusicImplFromJson(json);

  @override
  final String thirdPartyId;
  @override
  final String title;
  @override
  final String artist;
  @override
  final String audioUrl;
  @override
  final String? coverImage;

  @override
  String toString() {
    return 'PostMusic(thirdPartyId: $thirdPartyId, title: $title, artist: $artist, audioUrl: $audioUrl, coverImage: $coverImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostMusicImpl &&
            (identical(other.thirdPartyId, thirdPartyId) ||
                other.thirdPartyId == thirdPartyId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, thirdPartyId, title, artist, audioUrl, coverImage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostMusicImplCopyWith<_$PostMusicImpl> get copyWith =>
      __$$PostMusicImplCopyWithImpl<_$PostMusicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostMusicImplToJson(
      this,
    );
  }
}

abstract class _PostMusic implements PostMusic {
  const factory _PostMusic(
      {required final String thirdPartyId,
      required final String title,
      required final String artist,
      required final String audioUrl,
      final String? coverImage}) = _$PostMusicImpl;

  factory _PostMusic.fromJson(Map<String, dynamic> json) =
      _$PostMusicImpl.fromJson;

  @override
  String get thirdPartyId;
  @override
  String get title;
  @override
  String get artist;
  @override
  String get audioUrl;
  @override
  String? get coverImage;
  @override
  @JsonKey(ignore: true)
  _$$PostMusicImplCopyWith<_$PostMusicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
