// @dart=2.9

import 'package:calendar/ui/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

const appGroupID = "group.app.akiho.calendar";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("ja_JP");
  await Firebase.initializeApp();
  await FirebaseAuth.instance.setSettings(userAccessGroup: "app.akiho.calendar.keychain");
  await FirebaseAuth.instance.signInAnonymously();
  HomeWidget.setAppGroupId(appGroupID);

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
