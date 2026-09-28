import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/status/states/status_state.dart';

final statusProvider = StateNotifierProvider<StatusNotifier, StatusState>(
      (ref) => StatusNotifier(),
);

class StatusNotifier extends StateNotifier<StatusState> {
  StatusNotifier() : super(const StatusState());

  void addRecentUpdate(String name) {
    state = state.copyWith(recentUpdates: [...state.recentUpdates, name]);
  }

  void addViewedUpdate(String name) {
    state = state.copyWith(viewedUpdates: [...state.viewedUpdates, name]);
  }

  void setFabClicked(bool clicked) {
    state = state.copyWith(isFabClicked: clicked);
  }
}
