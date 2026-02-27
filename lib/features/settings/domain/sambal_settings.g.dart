// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sambal_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SambalSettings _$SambalSettingsFromJson(Map<String, dynamic> json) =>
    _SambalSettings(
      level0to3Price: (json['level0to3Price'] as num?)?.toDouble() ?? 0,
      level4to5Price: (json['level4to5Price'] as num?)?.toDouble() ?? 500,
      level6to7Price: (json['level6to7Price'] as num?)?.toDouble() ?? 1000,
    );

Map<String, dynamic> _$SambalSettingsToJson(_SambalSettings instance) =>
    <String, dynamic>{
      'level0to3Price': instance.level0to3Price,
      'level4to5Price': instance.level4to5Price,
      'level6to7Price': instance.level6to7Price,
    };
