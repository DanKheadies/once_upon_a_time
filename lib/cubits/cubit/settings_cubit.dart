import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'settings_state.dart';

class SettingsCubit extends HydratedCubit<SettingsState> {
  SettingsCubit() : super(SettingsState.initial());

  void rotateFonts() {
    SettingsFont currentFont = state.font;

    // if (currentFont == SettingsFont.alagard) {
    //   emit(state.copyWith(font: SettingsFont.holdMoney));
    // } else if (currentFont == SettingsFont.holdMoney) {
    //   emit(state.copyWith(font: SettingsFont.storybook));
    // } else if (currentFont == SettingsFont.storybook) {
    //   emit(state.copyWith(font: SettingsFont.alagard));
    // }
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
