import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/custom_bottom_nav_state.dart';

final customBottomNavProvider = StateNotifierProvider<CustomBottomNavNotifier, CustomBottomNavState>(
      (ref) => CustomBottomNavNotifier(),
);

class CustomBottomNavNotifier extends StateNotifier<CustomBottomNavState> {
  CustomBottomNavNotifier() : super(const CustomBottomNavState());

  void setPageIndex(int index) {
    state = state.copyWith(pageIndex: index);
  }
}
