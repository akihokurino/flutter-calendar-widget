import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/ui/calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("ja_JP");

  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: const CalendarPage(),
    builder: (context, child) {
      // 端末の文字サイズ設定を無効にする
      return MediaQuery(
        child: child!,
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      );
    },
  );

  runApp(app);
}
