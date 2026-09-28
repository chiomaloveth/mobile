import 'package:flutter/material.dart';

class StatusState {
  final List<String> recentUpdates;
  final List<String> viewedUpdates;
  final bool isFabClicked;

  const StatusState({
    this.recentUpdates = const [],
    this.viewedUpdates = const [],
    this.isFabClicked = false,
  });

  StatusState copyWith({
    List<String>? recentUpdates,
    List<String>? viewedUpdates,
    bool? isFabClicked,
  }) {
    return StatusState(
      recentUpdates: recentUpdates ?? this.recentUpdates,
      viewedUpdates: viewedUpdates ?? this.viewedUpdates,
      isFabClicked: isFabClicked ?? this.isFabClicked,
    );
  }
}
