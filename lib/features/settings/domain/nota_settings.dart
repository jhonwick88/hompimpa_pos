import 'package:freezed_annotation/freezed_annotation.dart';

part 'nota_settings.freezed.dart';
part 'nota_settings.g.dart';

@freezed
abstract class NotaSettings with _$NotaSettings {
  const factory NotaSettings({
    @Default('HOMPIMPA') String storeName,
    @Default('Spesialis Mie & Pangsit Level') String tagline,
    @Default('Dsn Bulak 01/05 Ds Nglaban') String address1,
    @Default('Kec. Loceret Kab. Nganjuk') String address2,
    @Default('085934345756') String phone,
    @Default('Terima kasih atas kunjungan Anda') String footerMessage,
  }) = _NotaSettings;

  factory NotaSettings.fromJson(Map<String, dynamic> json) => _$NotaSettingsFromJson(json);
}
