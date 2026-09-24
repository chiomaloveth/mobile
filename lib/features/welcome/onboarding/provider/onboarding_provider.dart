import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qik_talk/features/welcome/onboarding/provider/slider_state.dart';
import '../../../authentication/login/screens/login_screen.dart';


final sliderProvider =
StateNotifierProvider<SliderNotifier, SliderState>(
      (ref) => SliderNotifier(),
);

class SliderNotifier extends StateNotifier<SliderState> {
  SliderNotifier() : super(const SliderState());

  final PageController pageController = PageController();

  final List<Map<String, String>> slides = [
    {
      'img': 'images/slider_one.png',
      'textBold1': 'Group Chatting',
      'text1': 'Connect with multiple components in ',
      'text2': 'group chats.',
    },
    {
      'img': 'images/slider_two.png',
      'textBold1': 'Video and Voice Calls',
      'text1': "Instantly connect via video",
      'text2': 'and voice calls.',
    },
    {
      'img': 'images/slider_three.png',
      'textBold1': 'Message Encryption',
      'text1': 'Ensure privacy with encrypted',
      'text2': 'messages.',
    },
    {
      'img': 'images/slider_four.png',
      'textBold1': 'Cross-Platform Compatibility',
      'text1': 'Access chats on any device',
      'text2': 'seamlessly.',
    },
  ];

  /// ---------------- PAGE CHANGE ----------------
  void onPageChanged(int index) {
    state = state.copyWith(
      currentPage: index,
      isLastPage: index == slides.length - 1,
    );
  }

  /// ---------------- NEXT / GET STARTED ----------------
  void nextPage(BuildContext context) {
    if (!state.isLastPage) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LogInScreen()),
      );
    }
  }

  /// ---------------- SKIP ----------------
  void skip(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LogInScreen()),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
