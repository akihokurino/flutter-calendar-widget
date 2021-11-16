import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/provider/calendar.dart';
import 'package:flutter_calendar_widget/ui/registration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import 'transition.dart';

class CalendarPage extends HookConsumerWidget {
  static Widget init() {
    return CalendarPage(key: GlobalObjectKey(const Uuid().v4.toString()));
  }

  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarAction = ref.read(calendarProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        calendarAction.syncSchedules();
      });

      return () {};
    }, const []);

    final now = DateTime.now();

    final calendar = Container(
      margin: EdgeInsets.zero,
      child: TableCalendar(
        locale: 'ja_JP',
        firstDay: DateTime.utc(now.year - 1, 1, 1),
        lastDay: DateTime.utc(now.year + 1, 12, 31),
        focusedDay: calendarState.focusedDay,
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
        ),
        selectedDayPredicate: (day) {
          return isSameDay(calendarState.selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(calendarState.selectedDay, selectedDay)) {
            calendarAction.selectDay(selectedDay);
          }
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(calendarState.selectedDayText()),
      ),
      body: ModalProgressHUD(
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeData.dark().textTheme.bodyText1!.color!),
          ),
          opacity: 0.5,
          color: Colors.black,
          child: calendar,
          inAsyncCall: calendarState.shouldShowHud),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeData.dark().primaryColor,
        foregroundColor: ThemeData.dark().textTheme.bodyText1!.color!,
        child: const Icon(Icons.add),
        onPressed: () {
          modal(context, RegistrationPage.init());
        },
      ),
    );
  }
}
