import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/widgets.dart';

class AppPermissionsState {
  final PermissionStatus camera;
  final PermissionStatus microphone;
  final PermissionStatus photos;
  final PermissionStatus location;
  final bool isLoading;

  const AppPermissionsState({
    this.camera = PermissionStatus.denied,
    this.microphone = PermissionStatus.denied,
    this.photos = PermissionStatus.denied,
    this.location = PermissionStatus.denied,
    this.isLoading = false,
  });

  AppPermissionsState copyWith({
    PermissionStatus? camera,
    PermissionStatus? microphone,
    PermissionStatus? photos,
    PermissionStatus? location,
    bool? isLoading,
  }) {
    return AppPermissionsState(
      camera: camera ?? this.camera,
      microphone: microphone ?? this.microphone,
      photos: photos ?? this.photos,
      location: location ?? this.location,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final appPermissionsProvider =
    StateNotifierProvider<AppPermissionsNotifier, AppPermissionsState>(
      (ref) => AppPermissionsNotifier(),
    );

class AppPermissionsNotifier extends StateNotifier<AppPermissionsState>
    with WidgetsBindingObserver {
  AppPermissionsNotifier() : super(const AppPermissionsState()) {
    _init();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);
    refreshStatuses();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check permissions when user returns to app
      refreshStatuses();
    }
  }

  Future<void> refreshStatuses() async {
    state = state.copyWith(isLoading: true);

    final results = await Future.wait([
      Permission.camera.status,
      Permission.microphone.status,
      Permission.photos.status,
      Permission.location.status,
    ]);

    state = state.copyWith(
      camera: results[0],
      microphone: results[1],
      photos: results[2],
      location: results[3],
      isLoading: false,
    );
  }

  Future<void> togglePermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      // Cannot programmatically "revoke" on iOS/most Android,
      // but we can open settings if the user wants to disable it.
      await openAppSettings();
    } else {
      final result = await permission.request();
      if (result.isPermanentlyDenied) {
        await openAppSettings();
      }
    }

    await refreshStatuses();
  }
}
