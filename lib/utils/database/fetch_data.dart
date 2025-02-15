import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchData(
    DatabaseTables table, Map<String, Object> matchCondition) async {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> response =
      await supabase.from(table.name).select().match(matchCondition);
  print(matchCondition);
  print("-------------------------------");
  print(response);

  return response;
}
