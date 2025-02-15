import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int> getReferenceTable() async {
  final url = Uri.parse(
      'https://veiculos.fipe.org.br/api/veiculos/ConsultarTabelaDeReferencia');

  final headers = {
    "Content-Type": "application/json",
  };

  try {
    final response = await http.post(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final latestData = data.reduce((a, b) {
        final aDate = _getDate(a['Mes']);
        final bDate = _getDate(b['Mes']);
        return aDate.isAfter(bDate) ? a : b;
      });

      return latestData['Codigo'];
    } else {
      print('Request failed with status: ${response.statusCode}');
      print(response.body);
      return 318;
    }
  } catch (e) {
    print('Error: $e');
    return 318;
  }
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
