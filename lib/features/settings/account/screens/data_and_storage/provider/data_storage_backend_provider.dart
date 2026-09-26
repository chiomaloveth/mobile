import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:qik_talk/utilities/constants/app_strings/api_strings.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

class DataSettingsState {
  // Cellular (mobile data)
  final bool cellularPhotos;
  final bool cellularVideos;
  final bool cellularAudio;
  final bool cellularDocs;
  // Wi-Fi
  final bool wifiPhotos;
  final bool wifiVideos;
  final bool wifiAudio;
  final bool wifiDocs;
  // Roaming
  final bool roamingPhotos;
  final bool roamingVideos;
  final bool roamingAudio;
  final bool roamingDocs;

  final bool isLoading;
  final bool isSaving;
  final String? error;

  const DataSettingsState({
    this.cellularPhotos = true,
    this.cellularVideos = false,
    this.cellularAudio = true,
    this.cellularDocs = false,
    this.wifiPhotos = true,
    this.wifiVideos = true,
    this.wifiAudio = true,
    this.wifiDocs = true,
    this.roamingPhotos = false,
    this.roamingVideos = false,
    this.roamingAudio = false,
    this.roamingDocs = false,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  DataSettingsState copyWith({
    bool? cellularPhotos,
    bool? cellularVideos,
    bool? cellularAudio,
    bool? cellularDocs,
    bool? wifiPhotos,
    bool? wifiVideos,
    bool? wifiAudio,
    bool? wifiDocs,
    bool? roamingPhotos,
    bool? roamingVideos,
    bool? roamingAudio,
    bool? roamingDocs,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return DataSettingsState(
      cellularPhotos: cellularPhotos ?? this.cellularPhotos,
      cellularVideos: cellularVideos ?? this.cellularVideos,
      cellularAudio: cellularAudio ?? this.cellularAudio,
      cellularDocs: cellularDocs ?? this.cellularDocs,
      wifiPhotos: wifiPhotos ?? this.wifiPhotos,
      wifiVideos: wifiVideos ?? this.wifiVideos,
      wifiAudio: wifiAudio ?? this.wifiAudio,
      wifiDocs: wifiDocs ?? this.wifiDocs,
      roamingPhotos: roamingPhotos ?? this.roamingPhotos,
      roamingVideos: roamingVideos ?? this.roamingVideos,
      roamingAudio: roamingAudio ?? this.roamingAudio,
      roamingDocs: roamingDocs ?? this.roamingDocs,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

final dataSettingsProvider =
    StateNotifierProvider<DataSettingsNotifier, DataSettingsState>(
  (ref) => DataSettingsNotifier(),
);

class DataSettingsNotifier extends StateNotifier<DataSettingsState> {
  DataSettingsNotifier() : super(const DataSettingsState()) {
    _loadFromCacheThenBackend();
  }

  final SaveValues _saveValues = SaveValues();

  // Cache keys
  static const _kCellularPhotos = 'ds_cellular_photos';
  static const _kCellularVideos = 'ds_cellular_videos';
  static const _kCellularAudio  = 'ds_cellular_audio';
  static const _kCellularDocs   = 'ds_cellular_docs';
  static const _kWifiPhotos     = 'ds_wifi_photos';
  static const _kWifiVideos     = 'ds_wifi_videos';
  static const _kWifiAudio      = 'ds_wifi_audio';
  static const _kWifiDocs       = 'ds_wifi_docs';
  static const _kRoamPhotos     = 'ds_roam_photos';
  static const _kRoamVideos     = 'ds_roam_videos';
  static const _kRoamAudio      = 'ds_roam_audio';
  static const _kRoamDocs       = 'ds_roam_docs';

  bool _parseBool(String? v, bool fallback) =>
      v == null ? fallback : v == 'true';

  Future<void> _loadFromCacheThenBackend() async {
    // 1. Show cached values immediately
    final s = DataSettingsState(
      cellularPhotos: _parseBool(await _saveValues.getString(_kCellularPhotos), true),
      cellularVideos: _parseBool(await _saveValues.getString(_kCellularVideos), false),
      cellularAudio:  _parseBool(await _saveValues.getString(_kCellularAudio),  true),
      cellularDocs:   _parseBool(await _saveValues.getString(_kCellularDocs),   false),
      wifiPhotos:     _parseBool(await _saveValues.getString(_kWifiPhotos),     true),
      wifiVideos:     _parseBool(await _saveValues.getString(_kWifiVideos),     true),
      wifiAudio:      _parseBool(await _saveValues.getString(_kWifiAudio),      true),
      wifiDocs:       _parseBool(await _saveValues.getString(_kWifiDocs),       true),
      roamingPhotos:  _parseBool(await _saveValues.getString(_kRoamPhotos),     false),
      roamingVideos:  _parseBool(await _saveValues.getString(_kRoamVideos),     false),
      roamingAudio:   _parseBool(await _saveValues.getString(_kRoamAudio),      false),
      roamingDocs:    _parseBool(await _saveValues.getString(_kRoamDocs),       false),
    );
    state = s;
    // 2. Refresh from backend
    await loadSettings();
  }

  Future<void> _persistToCache(DataSettingsState s) async {
    await _saveValues.saveString(_kCellularPhotos, s.cellularPhotos.toString());
    await _saveValues.saveString(_kCellularVideos, s.cellularVideos.toString());
    await _saveValues.saveString(_kCellularAudio,  s.cellularAudio.toString());
    await _saveValues.saveString(_kCellularDocs,   s.cellularDocs.toString());
    await _saveValues.saveString(_kWifiPhotos,     s.wifiPhotos.toString());
    await _saveValues.saveString(_kWifiVideos,     s.wifiVideos.toString());
    await _saveValues.saveString(_kWifiAudio,      s.wifiAudio.toString());
    await _saveValues.saveString(_kWifiDocs,       s.wifiDocs.toString());
    await _saveValues.saveString(_kRoamPhotos,     s.roamingPhotos.toString());
    await _saveValues.saveString(_kRoamVideos,     s.roamingVideos.toString());
    await _saveValues.saveString(_kRoamAudio,      s.roamingAudio.toString());
    await _saveValues.saveString(_kRoamDocs,       s.roamingDocs.toString());
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final response = await http.get(
        Uri.parse('${ApiStrings.baseUri}user/user-info'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        Map<String, dynamic>? ds;
        if (body['success'] == true && body['data'] is Map) {
          ds = body['data']['dataSettings'];
        }
        if (ds != null) {
          final cellular = ds['autoDownload']?['cellular'];
          final wifi = ds['autoDownload']?['wifi'];
          final roaming = ds['autoDownload']?['roaming'];
          final next = state.copyWith(
            isLoading: false,
            cellularPhotos: cellular?['photos']    ?? true,
            cellularVideos: cellular?['videos']    ?? false,
            cellularAudio:  cellular?['audio']     ?? true,
            cellularDocs:   cellular?['documents'] ?? false,
            wifiPhotos:     wifi?['photos']        ?? true,
            wifiVideos:     wifi?['videos']        ?? true,
            wifiAudio:      wifi?['audio']         ?? true,
            wifiDocs:       wifi?['documents']     ?? true,
            roamingPhotos:  roaming?['photos']     ?? false,
            roamingVideos:  roaming?['videos']     ?? false,
            roamingAudio:   roaming?['audio']      ?? false,
            roamingDocs:    roaming?['documents']  ?? false,
          );
          state = next;
          await _persistToCache(next);
          return;
        }
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleCellular(String key, bool value) async {
    state = _applyCellular(key, value);
    await _save();
    await _persistToCache(state);
  }

  Future<void> toggleWifi(String key, bool value) async {
    state = _applyWifi(key, value);
    await _save();
    await _persistToCache(state);
  }

  Future<void> toggleRoaming(String key, bool value) async {
    state = _applyRoaming(key, value);
    await _save();
    await _persistToCache(state);
  }

  DataSettingsState _applyCellular(String key, bool value) {
    switch (key) {
      case 'photos': return state.copyWith(cellularPhotos: value);
      case 'videos': return state.copyWith(cellularVideos: value);
      case 'audio':  return state.copyWith(cellularAudio: value);
      case 'docs':   return state.copyWith(cellularDocs: value);
      default:       return state;
    }
  }

  DataSettingsState _applyWifi(String key, bool value) {
    switch (key) {
      case 'photos': return state.copyWith(wifiPhotos: value);
      case 'videos': return state.copyWith(wifiVideos: value);
      case 'audio':  return state.copyWith(wifiAudio: value);
      case 'docs':   return state.copyWith(wifiDocs: value);
      default:       return state;
    }
  }

  DataSettingsState _applyRoaming(String key, bool value) {
    switch (key) {
      case 'photos': return state.copyWith(roamingPhotos: value);
      case 'videos': return state.copyWith(roamingVideos: value);
      case 'audio':  return state.copyWith(roamingAudio: value);
      case 'docs':   return state.copyWith(roamingDocs: value);
      default:       return state;
    }
  }

  Future<void> _save() async {
    state = state.copyWith(isSaving: true);
    try {
      final token = await _saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
      final payload = {
        'dataSettings': {
          'autoDownload': {
            'cellular': {
              'photos': state.cellularPhotos,
              'videos': state.cellularVideos,
              'audio': state.cellularAudio,
              'documents': state.cellularDocs,
            },
            'wifi': {
              'photos': state.wifiPhotos,
              'videos': state.wifiVideos,
              'audio': state.wifiAudio,
              'documents': state.wifiDocs,
            },
            'roaming': {
              'photos': state.roamingPhotos,
              'videos': state.roamingVideos,
              'audio': state.roamingAudio,
              'documents': state.roamingDocs,
            },
          },
        },
      };
      await http.put(
        Uri.parse('${ApiStrings.baseUri}user/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
    } catch (_) {
      // Silent fail — local state already updated
    } finally {
      if (mounted) state = state.copyWith(isSaving: false);
    }
  }
}
