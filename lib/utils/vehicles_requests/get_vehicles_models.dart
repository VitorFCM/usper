import 'dart:convert';
import 'package:usper/utils/http_post.dart';

Future<List<String>> getVehiclesModels(
    int makerCode, int tableCode, int vehicleTypeCode) async {
  const String url =
      "https://veiculos.fipe.org.br/api/veiculos/ConsultarModelos";

  final body = json.encode({
    "codigoTipoVeiculo": vehicleTypeCode,
    "codigoTabelaReferencia": tableCode,
    "codigoMarca": makerCode,
  });

  final headers = {
    "Content-Type": "application/json",
  };

  String? response = await httpPost(url, headers: headers, body: body);

  if (response == null) {
    return [];
  }

  Map<String, dynamic> modelsMap = json.decode(response);

  return modelsMap["Modelos"].map<String>((model) {
    return model['Label'].toString();
  }).toList();
}
