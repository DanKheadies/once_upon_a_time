import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial()) {
    if (state.randomizeFont) randomizeFont();
  }

  void randomizeFont() {
    SettingsFont currentFont = state.font;
    List<SettingsFont> fontsList = [];
    for (var font in SettingsFont.values) {
      fontsList.add(font);
    }
    fontsList.removeWhere((font) => font == currentFont);
    int index = Random().nextInt(fontsList.length);
    emit(state.copyWith(font: fontsList[index], randomizeFont: true));
  }

  void rotateFonts() {
    SettingsFont currentFont = state.font;

    emit(
      state.copyWith(
        font: currentFont == SettingsFont.zero
            ? SettingsFont.alagard
            : currentFont == SettingsFont.alagard
            ? SettingsFont.holdMoney
            : currentFont == SettingsFont.holdMoney
            ? SettingsFont.storybook
            : currentFont == SettingsFont.storybook
            ? SettingsFont.zero
            : SettingsFont.zero,
        randomizeFont: false,
      ),
    );
  }

  void toggleButtons() {
    emit(state.copyWith(showActionButtons: !state.showActionButtons));
  }

  @override
  SettingsState? fromJson(Map<String, dynamic> json) {
    return SettingsState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(SettingsState state) {
    return state.toJson();
  }
}
