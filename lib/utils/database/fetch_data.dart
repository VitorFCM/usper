import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<List<Map<String, dynamic>>> fetchData(
    DatabaseTables table, Map<String, Object?> matchCondition) async {
  final supabase = Supabase.instance.client;

  var query = supabase.from(table.name).select();

  matchCondition.forEach((key, value) {
    if (value == null) {
      query = query.filter(key, "eq", null);
    } else {
      query = query.match({key: value});
    }
  });

  List<Map<String, dynamic>> response = await query;

  return response;
}
