import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updateData(DatabaseTables table, Map<String, Object> data,
    Map<String, Object> filters) async {
  final supabase = Supabase.instance.client;

  var query = supabase.from(table.name).update(data);

  filters.forEach((key, value) {
    query = query.eq(key, value);
  });

  await query;
}
