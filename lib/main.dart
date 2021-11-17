// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/ui/calendar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("ja_JP");
  await Firebase.initializeApp();

  await FirebaseAuth.instance.signInAnonymously();

  final app = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: CalendarPage.init(),
    builder: (context, child) {
      // 端末の文字サイズ設定を無効にする
      return MediaQuery(
        child: child,
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      );
    },
  );

  runApp(
    ProviderScope(
      child: app,
    ),
  );
}
