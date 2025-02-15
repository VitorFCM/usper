import 'dart:convert';
import 'package:usper/utils/http_post.dart';

Future<List<String>> getVehiclesModels(
    int makerCode, int tableCode, int vehicleTypeCode) async {
  final url =
      Uri.parse('https://veiculos.fipe.org.br/api/veiculos/ConsultarModelos');

  final body = json.encode({
    "codigoTipoVeiculo": vehicleTypeCode,
    "codigoTabelaReferencia": tableCode,
    "codigoMarca": makerCode,
  });

  final headers = {
    "Content-Type": "application/json",
  };

  Map<String, dynamic>? response = await httpPost(url, headers, body);

  return response?["Modelos"].map<String>((model) {
    return model['Label'].toString();
  }).toList();
}
