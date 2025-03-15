import 'dart:convert';

import 'package:usper/utils/http_post.dart';

Future<List<String>> getUspCourses(int carrerCode) async {
  const String url =
      "https://uspdigital.usp.br/jupiterweb/dwr/call/plaincall/ControlePublicoDWR.listar.dwr";

  final headers = {
    "Content-Type": "text/plain",
    "Host": "uspdigital.usp.br",
    "Accept": "*/*",
    "Accept-Language": "pt-BR,pt;q=0.8,en-US;q=0.5,en;q=0.3",
    "Accept-Encoding": "gzip, deflate, br",
    "Origin": "https://uspdigital.usp.br",
    "Connection": "keep-alive",
    "Referer":
        "https://uspdigital.usp.br/jupiterweb/jupCarreira.jsp?codmnu=8275",
  };

  final String body = """callCount=1
nextReverseAjaxIndex=0
c0-scriptName=ControlePublicoDWR
c0-methodName=listar
c0-id=0
c0-param0=string:pubListarCursoEntrada
c0-e1=string:$carrerCode
c0-param1=Object_Object:{codclg:reference:c0-e1}
batchId=1
instanceId=0
page=%2Fjupiterweb%2FjupCarreira.jsp%3Fcodmnu%3D8275
scriptSessionId=6wwYHJZwexO6poUTffbHwYwsqKn!fO5FXlp/IjkFXlp-EAuclUssv""";

  final response = await httpPost(url, headers: headers, body: body);

  if (response == null) {
    return [""];
  }

  return _parseUspCourses(response);
}

List<String> _parseUspCourses(String response) {
  try {
    final regex = RegExp(r'handleCallback\("1","0",(\[.*?\])\);', dotAll: true);
    final match = regex.firstMatch(response);

    if (match == null) {
      return [];
    }

    String jsonString = match.group(1) ?? "";

    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\w+):(?=["\[{])'), (match) => '"${match.group(1)}":');

    final List<dynamic> list = json.decode(jsonString);

    return [for (var item in list) item["nomhab"] + " - " + item["perhab"]];
  } catch (e) {
    return [];
  }
}
