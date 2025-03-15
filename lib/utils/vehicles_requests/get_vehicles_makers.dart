import 'dart:convert';
import 'package:usper/utils/http_post.dart';

Future<Map<String, int?>?> getVehiclesMakers(
    int tableCode, int vehicleTypeCode) async {
  const String url =
      "https://veiculos.fipe.org.br/api/veiculos/ConsultarMarcas";

  final body = json.encode({
    "codigoTabelaReferencia": tableCode,
    "codigoTipoVeiculo": vehicleTypeCode,
  });

  final headers = {
    "Content-Type": "application/json",
  };

  String? response = await httpPost(url, headers: headers, body: body);

  if (response == null) return null;

  List<dynamic> makersList = json.decode(response);

  return {
    for (var item in makersList) item['Label']: int.tryParse(item['Value'])
  };
}
