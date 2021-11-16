import 'package:flutter/material.dart';

void replace(BuildContext context, Widget to) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => to,
      settings: RouteSettings(name: to.toString()),
    ),
  );
}

void root(BuildContext context, Widget to) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (BuildContext context) => to, settings: RouteSettings(name: to.toString())),
    ModalRoute.withName('/'),
  );
}

void push(BuildContext context, Widget to) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => to,
      settings: RouteSettings(name: to.toString()),
    ),
  );
}

void modal(BuildContext context, Widget to) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => to, settings: RouteSettings(name: to.toString()), fullscreenDialog: true));
}
