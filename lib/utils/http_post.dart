import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> httpPost(final String url,
    {Map<String, String>? headers, Object? body}) async {
  try {
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
