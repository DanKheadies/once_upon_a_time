part of 'settings_cubit.dart';

enum SettingsFont { alagard, holdMoney, storybook, zero }

class SettingsState with Equatable {
  final bool showActionButtons;
  final SettingsFont font;

  const SettingsState({required this.font, required this.showActionButtons});

  @override
  List<Object> get props => [font, showActionButtons];

  String? get fontFamily => font == SettingsFont.alagard
      ? 'Alagard'
      : font == SettingsFont.holdMoney
      ? 'HoldMoney'
      : font == SettingsFont.storybook
      ? 'Storybook'
      : font == SettingsFont.zero
      ? null // 'Default'
      : null; // 'Default';

  factory SettingsState.initial() {
    return SettingsState(font: SettingsFont.zero, showActionButtons: false);
  }

  SettingsState copyWith({bool? showActionButtons, SettingsFont? font}) {
    return SettingsState(
      font: font ?? this.font,
      showActionButtons: showActionButtons ?? this.showActionButtons,
    );
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    SettingsFont settingsFont = SettingsFont.values.firstWhere(
      (font) => font.name.toString() == json['font'],
    );

    return SettingsState(
      font: settingsFont,
      showActionButtons: json['showActionButtons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'font': font.name, 'showActionButtons': showActionButtons};
  }
}
