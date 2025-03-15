import 'dart:convert';

import 'package:usper/utils/http_post.dart';

Future<int> getReferenceTable() async {
  const String url =
      "https://veiculos.fipe.org.br/api/veiculos/ConsultarTabelaDeReferencia";

  final headers = {
    "Content-Type": "application/json",
  };

  String? response = await httpPost(url, headers: headers);

  if (response == null) {
    return 319;
  }
  List<dynamic> data = json.decode(response);

  final latestData = data.reduce((a, b) {
    final aDate = _getDate(a['Mes']);
    final bDate = _getDate(b['Mes']);
    return aDate.isAfter(bDate) ? a : b;
  });

  return latestData['Codigo'];
}

DateTime _getDate(String monthString) {
  final monthMap = {
    'janeiro': 1,
    'fevereiro': 2,
    'março': 3,
    'abril': 4,
    'maio': 5,
    'junho': 6,
    'julho': 7,
    'agosto': 8,
    'setembro': 9,
    'outubro': 10,
    'novembro': 11,
    'dezembro': 12,
  };

  final parts = monthString.toLowerCase().split('/');
  final month = monthMap[parts[0]] ?? 0;
  final year = int.tryParse(parts[1]) ?? 0;

  return DateTime(year, month);
}
