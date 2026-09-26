import 'package:equatable/equatable.dart';

class NotificationState extends Equatable {
  final bool messages;
  final bool sound;
  final bool vibrate;
  final bool calls;
  final bool groups;
  final bool showPreviews;

  const NotificationState({
    this.messages = true,
    this.sound = true,
    this.vibrate = true,
    this.calls = true,
    this.groups = false,
    this.showPreviews = true,
  });

  NotificationState copyWith({
    bool? messages,
    bool? sound,
    bool? vibrate,
    bool? calls,
    bool? groups,
    bool? showPreviews,
  }) {
    return NotificationState(
      messages: messages ?? this.messages,
      sound: sound ?? this.sound,
      vibrate: vibrate ?? this.vibrate,
      calls: calls ?? this.calls,
      groups: groups ?? this.groups,
      showPreviews: showPreviews ?? this.showPreviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "messages": messages,
      "sound": sound,
      "vibrate": vibrate,
      "calls": calls,
      "groups": groups,
    };
  }

  @override
  List<Object> get props => [messages, sound, vibrate, calls, groups, showPreviews];
}