import 'dart:convert';
import 'package:usper/utils/http_post.dart';

Future<Map<String, int?>?> getVehiclesMakers(
    int tableCode, int vehicleTypeCode) async {
  final url =
      Uri.parse('https://veiculos.fipe.org.br/api/veiculos/ConsultarMarcas');

  final body = json.encode({
    "codigoTabelaReferencia": tableCode,
    "codigoTipoVeiculo": vehicleTypeCode,
  });

  final headers = {
    "Content-Type": "application/json",
  };

  List<dynamic>? makersList = await httpPost(url, headers, body);

  if (makersList == null) return null;

  return {
    for (var item in makersList) item['Label']: int.tryParse(item['Value'])
  };
}
