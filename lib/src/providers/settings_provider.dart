import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SettingsState {
  final double fontSize;
  final int fontColor;
  final int bgColor;

  SettingsState({
    required this.fontSize,
    required this.fontColor,
    required this.bgColor,
  });

  SettingsState copyWith({
    double? fontSize,
    int? fontColor,
    int? bgColor,
  }) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      bgColor: bgColor ?? this.bgColor,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final box = Hive.box('resume_settings');
    return SettingsState(
      fontSize: (box.get('fontSize', defaultValue: 16.0) as num).toDouble(),
      fontColor: box.get('fontColor', defaultValue: Colors.black.value) as int,
      bgColor: box.get('bgColor', defaultValue: Colors.white.value) as int,
    );
  }

  void updateFontSize(double v) {
    Hive.box('resume_settings').put('fontSize', v);
    state = state.copyWith(fontSize: v);
  }

  void updateFontColor(int v) {
    Hive.box('resume_settings').put('fontColor', v);
    state = state.copyWith(fontColor: v);
  }

  void updateBgColor(int v) {
    Hive.box('resume_settings').put('bgColor', v);
    state = state.copyWith(bgColor: v);
  }
}

final settingsProvider =
NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
