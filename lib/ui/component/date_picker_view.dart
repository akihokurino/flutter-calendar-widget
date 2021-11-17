import 'package:calendar/library/date_picker/date_picker.dart';
import 'package:calendar/library/date_picker/date_picker_theme.dart';
import 'package:calendar/library/date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _theme = DateTimePickerTheme(
    backgroundColor: Colors.white,
    cancelTextStyle: ThemeData.dark().textTheme.caption,
    confirmTextStyle: TextStyle(
      color: ThemeData.dark().primaryColor,
    ));

class DatePickerView extends StatefulWidget {
  final String label;
  final DateTime? min;
  final DateTime? max;
  final DateTime initial;
  final DateTimePickerMode mode = DateTimePickerMode.date;
  final ValueChanged<DateTime> onChange;

  DatePickerView({this.label = "", this.min, this.max, required this.initial, required this.onChange});

  @override
  State<StatefulWidget> createState() => _DatePickerViewState();
}

class _DatePickerViewState extends State<DatePickerView> {
  DateTime? currentValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      height: widget.label.isNotEmpty ? 100 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(widget.label, style: ThemeData.dark().textTheme.caption),
                )
              : Container(),
          InkWell(
            onTap: () {
              _showAppDatePicker();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: ThemeData.dark().dividerColor, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(currentValue != null ? _convertDate(currentValue!) : "", style: ThemeData.dark().textTheme.bodyText1),
              ),
            ),
          )
        ],
      ),
    );
  }

  String _convertDate(DateTime datetime) {
    if (widget.mode == DateTimePickerMode.datetime) {
      final formatter = DateFormat('yyyy-MM-dd HH:mm', "ja_JP");
      return formatter.format(datetime);
    } else {
      final formatter = DateFormat('yyyy-MM-dd', "ja_JP");
      return formatter.format(datetime);
    }
  }

  void _showAppDatePicker() {
    final format = widget.mode == DateTimePickerMode.datetime ? "yyyy年MM月dd日,H時:m分" : "yyyy年,MM月,dd日";
    DatePicker.showDatePicker(context,
        pickerMode: widget.mode,
        locale: DateTimePickerLocale.jp,
        initialDateTime: widget.initial,
        minDateTime: widget.min,
        maxDateTime: widget.max,
        pickerTheme: _theme,
        dateFormat: format, onChange: (datetime, index) {
      widget.onChange(datetime);
      setState(() {
        currentValue = datetime;
      });
    }, onConfirm: (datetime, index) {
      widget.onChange(datetime);
      setState(() {
        currentValue = datetime;
      });
    });
  }
}
