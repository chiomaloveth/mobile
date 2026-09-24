import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utilities/services/app_pref_helper.dart';
import '../../../../utilities/database/save_values.dart';


enum SplashState {
  loading,
  loggedIn,
  loggedOut,
}

final splashProvider =
StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(SplashState.loading);

  final SaveValues saveValues = SaveValues();

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 5));

    final token = await saveValues.getString(AppPreferenceHelper.AUTH_TOKEN);
    final userId = await saveValues.getString(AppPreferenceHelper.ID);
    print(userId);

    if (token != null && token.isNotEmpty) {
      state = SplashState.loggedIn;
    } else {
      state = SplashState.loggedOut;
    }
  }
}
