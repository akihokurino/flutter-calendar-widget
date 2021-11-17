import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/model/schedule.dart';
import 'package:flutter_calendar_widget/provider/calendar.dart';
import 'package:flutter_calendar_widget/ui/component/dialog.dart';
import 'package:flutter_calendar_widget/ui/registration.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

import 'transition.dart';

class CalendarPage extends HookConsumerWidget {
  static Widget init() {
    return CalendarPage(key: GlobalObjectKey(const Uuid().v4()));
  }

  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final calendarState = ref.watch(calendarProvider);
    final calendarAction = ref.read(calendarProvider.notifier);

    useEffect(() {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        calendarAction.syncSchedules(now).then((err) {
          if (err != null) {
            AppDialog().showErrorAlert(context, err);
            return;
          }
        });
      });

      return () {};
    }, const []);

    final calendar = TableCalendar(
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
        onPageChanged: (date) {
          calendarAction.focusDay(date);
          calendarAction.syncSchedules(date).then((err) {
            if (err != null) {
              AppDialog().showErrorAlert(context, err);
              return;
            }
          });
        },
        eventLoader: EventMaker(schedules: calendarState.schedulesInMonth).getLoader(),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 5,
                bottom: 5,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red[300],
                  ),
                  width: 16.0,
                  height: 16.0,
                  child: Center(
                    child: Text(
                      '${events.length}',
                      style: ThemeData.dark().textTheme.bodyText1,
                    ),
                  ),
                ),
              );
            }
          },
        ));

    const double appBarHeight = 50;
    final calendarHeight = calendar.rowHeight * 6 + calendar.daysOfWeekHeight + 70;
    final listHeight = MediaQuery.of(context).size.height - appBarHeight - calendarHeight - 50;

    final content = Container(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: calendarHeight,
            margin: EdgeInsets.zero,
            child: calendar,
          ),
          Container(
            height: listHeight,
            margin: EdgeInsets.zero,
            child: ListView.builder(
              itemCount: calendarState.schedulesInDay().length,
              itemBuilder: (BuildContext context, int index) {
                final schedule = calendarState.schedulesInDay()[index];
                return Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(schedule.name, style: ThemeData.dark().textTheme.bodyText1),
                      ),
                      Container(
                          width: 70,
                          child: Text(schedule.dateDisplayText(), style: ThemeData.dark().textTheme.caption, textAlign: TextAlign.right),
                          margin: const EdgeInsets.only(left: 10))
                    ],
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ThemeData.dark().dividerColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: AppBar(
          title: Text(calendarState.selectedDayText()),
          centerTitle: true,
        ),
      ),
      body: ModalProgressHUD(
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeData.dark().textTheme.bodyText1!.color!),
          ),
          opacity: 0.5,
          color: Colors.black,
          child: content,
          inAsyncCall: calendarState.shouldShowHud),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ThemeData.dark().primaryColor,
        foregroundColor: ThemeData.dark().textTheme.bodyText1!.color!,
        child: const Icon(Icons.add),
        onPressed: () {
          modal(context, RegistrationPage.init(() {
            calendarAction.syncSchedules(calendarState.focusedDay).then((err) {
              if (err != null) {
                AppDialog().showErrorAlert(context, err);
                return;
              }
            });
          }));
        },
      ),
    );
  }
}

typedef EventLoader = List<dynamic> Function(DateTime day);

class EventMaker {
  final List<Schedule> schedules;

  EventMaker({required this.schedules});

  int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  EventLoader getLoader() {
    final events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: _getHashCode,
    );

    Map<DateTime, List<Schedule>> map = {};
    for (var schedule in schedules) {
      if (map.containsKey(schedule.date())) {
        map[schedule.date()]!.add(schedule);
      } else {
        map[schedule.date()] = [schedule];
      }
    }

    events.addAll(map);

    return (DateTime day) {
      return events[day] ?? [];
    };
  }
}
