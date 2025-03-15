import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> updateData(DatabaseTables table, Map<String, Object> data,
    MapEntry<String, Object> itemKey) async {
  final supabase = Supabase.instance.client;
  await supabase.from(table.name).update(data).eq(itemKey.key, itemKey.value);
}
