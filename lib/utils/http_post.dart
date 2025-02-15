import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> httpPost(final url, final headers, final body) async {
  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
