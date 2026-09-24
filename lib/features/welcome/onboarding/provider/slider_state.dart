import 'package:flutter/foundation.dart';

@immutable
class SliderState {
  final int currentPage;
  final bool isLastPage;

  const SliderState({
    this.currentPage = 0,
    this.isLastPage = false,
  });

  SliderState copyWith({
    int? currentPage,
    bool? isLastPage,
  }) {
    return SliderState(
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
