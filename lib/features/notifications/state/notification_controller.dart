import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_settings_services.dart';
import 'notification_state.dart';

final notificationServiceProvider =
    Provider((ref) => NotificationSettingsServices());

final notificationSettingsProvider =
    StateNotifierProvider<NotificationController, AsyncValue<NotificationState>>(
        (ref) => NotificationController(ref.read(notificationServiceProvider)));

class NotificationController
    extends StateNotifier<AsyncValue<NotificationState>> {
  final NotificationSettingsServices _services;

  NotificationController(this._services)
      : super(const AsyncValue.loading()) {
    _init();
  }

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Load from local cache first (instant), then refresh from backend.
  Future<void> _init() async {
    await _loadFromCache();
    await _loadFromBackend();
  }

  Future<void> _loadFromCache() async {
    try {
      final cached = await _services.getCachedSettings();
      if (cached != null) {
        state = AsyncValue.data(_notifStateFromMap(cached));
      }
    } catch (_) {
      // Ignore cache errors — backend will fill in
    }
  }

  Future<void> _loadFromBackend() async {
    try {
      final data = await _services.fetchNotificationSettings();
      state = AsyncValue.data(_notifStateFromMap(data));
    } catch (_) {
      // If backend fails but we already have cached data, keep it
      if (state is! AsyncData) {
        state = const AsyncValue.data(NotificationState());
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  NotificationState _notifStateFromMap(Map<String, dynamic> map) {
    return NotificationState(
      messages: map['messages'] as bool? ?? true,
      sound: map['sound'] as bool? ?? true,
      vibrate: map['vibrate'] as bool? ?? true,
      calls: map['calls'] as bool? ?? true,
      groups: map['groups'] as bool? ?? false,
      showPreviews: map['showPreviews'] as bool? ?? true,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<void> updateSetting({
    bool? messages,
    bool? sound,
    bool? vibrate,
    bool? calls,
    bool? groups,
    bool? showPreviews,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newState = currentState.copyWith(
      messages: messages,
      sound: sound,
      vibrate: vibrate,
      calls: calls,
      groups: groups,
      showPreviews: showPreviews,
    );

    // Optimistic update
    state = AsyncValue.data(newState);

    try {
      await _services.updateNotificationSettings(data: newState.toJson());
    } catch (e, stack) {
      // Rollback on error
      state = AsyncValue.data(currentState);
    }
  }

  Future<void> resetSettings() async {
    const defaults = NotificationState();
    state = const AsyncValue.data(defaults);
    try {
      await _services.updateNotificationSettings(data: defaults.toJson());
    } catch (_) {
      // Silently ignore — UI already shows defaults
    }
  }

  /// Force a fresh fetch from the backend (e.g. pull-to-refresh).
  Future<void> refresh() => _loadFromBackend();
}
