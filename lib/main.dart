import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qik_talk/main_utility.dart';
import 'package:qik_talk/quick_talk_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qik_talk/features/settings/theme/provider/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  await MainUtility.asyncActions();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) {
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const QuickTalkApp(),
      ),
    );
  });
}
