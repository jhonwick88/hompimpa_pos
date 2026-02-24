// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotaSettings _$NotaSettingsFromJson(Map<String, dynamic> json) =>
    _NotaSettings(
      storeName: json['storeName'] as String? ?? 'HOMPIMPA',
      tagline: json['tagline'] as String? ?? 'Spesialis Mie & Pangsit Level',
      address1: json['address1'] as String? ?? 'Dsn Bulak 01/05 Ds Nglaban',
      address2: json['address2'] as String? ?? 'Kec. Loceret Kab. Nganjuk',
      phone: json['phone'] as String? ?? '085934345756',
      footerMessage:
          json['footerMessage'] as String? ??
          'Terima kasih atas kunjungan Anda',
    );

Map<String, dynamic> _$NotaSettingsToJson(_NotaSettings instance) =>
    <String, dynamic>{
      'storeName': instance.storeName,
      'tagline': instance.tagline,
      'address1': instance.address1,
      'address2': instance.address2,
      'phone': instance.phone,
      'footerMessage': instance.footerMessage,
    };
