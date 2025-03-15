import 'dart:async';

import 'package:usper/constants/datatbase_tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Stream listenData(DatabaseTables table) {
  final StreamController _parsedData =
      StreamController.broadcast();
  final supabase = Supabase.instance.client;
  return supabase.from('countries')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data));
}
