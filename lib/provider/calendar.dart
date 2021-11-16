import 'package:flutter_calendar_widget/model/errors.dart';
import 'package:flutter_calendar_widget/model/schedule.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> syncSchedules() async {
    state = state.setShouldHud(true);

    await Future.delayed(const Duration(seconds: 3));

    state = state.setSchedules([]);
    state = state.setShouldHud(false);
  }

  Future<AppError?> selectDay(DateTime dt) async {
    state = state.setSelectedDay(dt);
  }

  Future<AppError?> registerSchedule(DateTime? date, String name) async {
    state = state.setShouldHud(true);

    await Future.delayed(const Duration(seconds: 3));

    state = state.setShouldHud(false);
  }
}

class _State {
  final bool shouldShowHud;
  final List<Schedule> schedules;
  final DateTime focusedDay;
  final DateTime selectedDay;

  String selectedDayText() {
    var formatter = DateFormat('yyyy年MM月dd日', "ja_JP");
    return formatter.format(selectedDay);
  }

  _State({required this.shouldShowHud, required this.schedules, required this.focusedDay, required this.selectedDay});

  static _State init() {
    return _State(shouldShowHud: false, schedules: [], focusedDay: DateTime.now(), selectedDay: DateTime.now());
  }

  _State setShouldHud(bool should) {
    return _State(shouldShowHud: should, schedules: schedules, focusedDay: focusedDay, selectedDay: selectedDay);
  }

  _State setSchedules(List<Schedule> items) {
    return _State(shouldShowHud: shouldShowHud, schedules: items, focusedDay: focusedDay, selectedDay: selectedDay);
  }

  _State setSelectedDay(DateTime dt) {
    return _State(shouldShowHud: shouldShowHud, schedules: schedules, focusedDay: focusedDay, selectedDay: dt);
  }
}

final calendarProvider = StateNotifierProvider<_Provider, _State>((_) => _Provider());
