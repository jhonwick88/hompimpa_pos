import 'package:freezed_annotation/freezed_annotation.dart';

part 'sambal_settings.freezed.dart';
part 'sambal_settings.g.dart';

@freezed
abstract class SambalSettings with _$SambalSettings {
  const SambalSettings._();
  const factory SambalSettings({
    @Default(0) double level0to3Price,
    @Default(500) double level4to5Price,
    @Default(1000) double level6to7Price,
  }) = _SambalSettings;

  factory SambalSettings.fromJson(Map<String, dynamic> json) => _$SambalSettingsFromJson(json);
}
