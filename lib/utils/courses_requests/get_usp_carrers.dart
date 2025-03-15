import 'dart:convert';

import 'package:usper/utils/http_post.dart';

Future<Map<int, String>> getUspCarrers() async {
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

  const String body = """callCount=1
nextReverseAjaxIndex=0
c0-scriptName=ControlePublicoDWR
c0-methodName=listar
c0-id=0
c0-param0=string:pubListarColegiado
c0-e1=string:XXX
c0-e2=string:0
c0-param1=Object_Object:{pfxdisval:reference:c0-e1, codcg:reference:c0-e2}
batchId=0
instanceId=0
page=%2Fjupiterweb%2FjupCarreira.jsp%3Fcodmnu%3D8275
scriptSessionId=6wwYHJZwexO6poUTffbHwYwsqKn!fO5FXlp/IjkFXlp-EAuclUssv""";

  final response = await httpPost(url, headers: headers, body: body);

  if (response == null) {
    return {};
  }

  print("Resposta da API:");
  print(_parseUspCarrers(response));

  return _parseUspCarrers(response);
}

Map<int, String> _parseUspCarrers(String response) {
  try {
    final regex = RegExp(r'handleCallback\("0","0",(.*?)\);', dotAll: true);
    final match = regex.firstMatch(response);

    if (match == null) {
      return {};
    }

    String jsonString = match.group(1) ?? "";

    jsonString = jsonString.replaceAllMapped(
        RegExp(r'(\w+):'), (match) => '"${match.group(1)}":');

    final List<dynamic> list = json.decode(jsonString);

    return {for (var item in list) int.parse(item["codclg"]): item["nomclg"]};
  } catch (e) {
    return {};
  }
}
