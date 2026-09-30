import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:qik_talk/utilities/services/global_socket_service.dart';
import 'package:qik_talk/utilities/database/save_values.dart';
import 'package:qik_talk/utilities/services/app_pref_helper.dart';

/// Manages realtime presence updates with immediate online/offline transitions.
/// This service:
/// - Tracks the user's online/offline state
/// - Broadcasts to all listeners when state changes
/// - Handles socket emissions and lifecycle events
/// - Prevents race conditions with debouncing
class PresenceManager {
  static final PresenceManager _instance = PresenceManager._internal();
  factory PresenceManager() => _instance;
  PresenceManager._internal();

  final GlobalSocketService _socketService = GlobalSocketService();
  final _presenceController = StreamController<PresenceState>.broadcast();

  PresenceState _currentState = PresenceState.offline;
  Timer? _debounceTimer;
  String? _cachedUserId;

  /// Stream of presence state changes
  Stream<PresenceState> get presenceStream => _presenceController.stream;

  /// Current presence state
  PresenceState get currentState => _currentState;

  /// Initialize presence manager and listen to socket events
  Future<void> initialize() async {
    try {
      _cachedUserId = await SaveValues().getString(AppPreferenceHelper.ID);
      debugPrint('✅ PresenceManager initialized for user: $_cachedUserId');

      // Listen to socket connection status changes
      _socketService.connectionStatus.listen((status) {
        if (status == ConnectionStatus.connected) {
          _setPresenceOnline();
        } else if (status == ConnectionStatus.disconnected) {
          _setPresenceOffline();
        }
      });
    } catch (e) {
      debugPrint('❌ PresenceManager initialization error: $e');
    }
  }

  /// Mark user as online (debounced to prevent rapid toggles)
  void setOnline() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 100),
      _setPresenceOnline,
    );
  }

  /// Mark user as offline (debounced to prevent rapid toggles)
  void setOffline() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 100),
      _setPresenceOffline,
    );
  }

  /// Internal method to actually set online state
  void _setPresenceOnline() {
    if (_currentState == PresenceState.online) return;

    _currentState = PresenceState.online;
    _presenceController.add(_currentState);
    debugPrint('🟢 PresenceManager: User ONLINE');

    // Emit to socket if connected
    if (_socketService.isConnected && _cachedUserId != null) {
      _socketService.emit('user online', _cachedUserId);
      debugPrint('📤 Emitted user online to socket');
    }
  }

  /// Internal method to actually set offline state
  void _setPresenceOffline() {
    if (_currentState == PresenceState.offline) return;

    _currentState = PresenceState.offline;
    _presenceController.add(_currentState);
    debugPrint('🔴 PresenceManager: User OFFLINE');

    // Emit to socket if connected
    if (_socketService.isConnected && _cachedUserId != null) {
      _socketService.emit('user offline', _cachedUserId);
      debugPrint('📤 Emitted user offline to socket');
    }
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    _cachedUserId = await SaveValues().getString(AppPreferenceHelper.ID);
    return _cachedUserId;
  }

  /// Dispose and cleanup
  void dispose() {
    _debounceTimer?.cancel();
    _presenceController.close();
  }
}

/// Presence state enum
enum PresenceState { online, offline }

/// Extension for string representation
extension PresenceStateExtension on PresenceState {
  String get displayName {
    switch (this) {
      case PresenceState.online:
        return 'Online';
      case PresenceState.offline:
        return 'Offline';
    }
  }

  bool get isOnline => this == PresenceState.online;
}
