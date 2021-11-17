import 'package:calendar/ui/component/buttons.dart';
import 'package:flutter/material.dart';

class AppDialog {
  static final AppDialog _singleton = AppDialog._internal();

  factory AppDialog() {
    return _singleton;
  }

  AppDialog._internal();

  bool _isShown = false;

  void showErrorAlert(BuildContext context, dynamic e) {
    if (_isShown) {
      return;
    }

    _isShown = true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(e.toString(), style: ThemeData.dark().textTheme.bodyText1),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.zero,
              child: GhostButton(
                  text: "閉じる",
                  color: ThemeData.dark().textTheme.bodyText1!.color!,
                  onClick: () {
                    Navigator.pop(context);
                  }),
              width: 80,
            ),
          ],
        );
      },
    ).then((res) async {
      _isShown = false;
    });
  }
}
