import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> deleteData(DatabaseTables table, Map<String, Object> data) async {
  final supabase = Supabase.instance.client;
  await supabase.from(table.name).delete().match(data);
}
