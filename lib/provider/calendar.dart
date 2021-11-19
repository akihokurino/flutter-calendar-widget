import 'package:calendar/model/errors.dart';
import 'package:calendar/model/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> syncSchedules(DateTime dt) async {
    final dateYM = DateFormat('yyyy-MM', "ja_JP").format(dt);
    final loginId = FirebaseAuth.instance.currentUser!.uid;

    state = state.setSchedulesInMonth([]);

    try {
      final ref = FirebaseFirestore.instance.collection("schedule/$loginId/$dateYM");
      final snapshots = await ref.orderBy("createdAtTimestamp").get();
      final schedules = snapshots.docs.map((snap) => Schedule.fromFirestore(snap.data())).toList();
      state = state.setSchedulesInMonth(schedules);
    } catch (e) {
      return AppError("エラーが発生しました");
    }
  }

  Future<AppError?> selectDay(DateTime dt) async {
    HomeWidget.saveWidgetData<String>("selectedDate", DateFormat("yyyy-MM-dd", "ja_JP").format(dt));
    _updateWidget();

    state = state.setSelectedDay(dt);
  }

  Future<AppError?> focusDay(DateTime dt) async {
    HomeWidget.saveWidgetData<String>("focusedDate", DateFormat("yyyy-MM-dd", "ja_JP").format(dt));
    _updateWidget();

    state = state.setFocusedDay(dt);
  }

  Future<AppError?> registerSchedule(DateTime? date, String name) async {
    if (date == null || name.isEmpty) {
      return AppError("不正なパラメータです");
    }
    final schedule = Schedule.create(date, name);
    final loginId = FirebaseAuth.instance.currentUser!.uid;

    state = state.setShouldHud(true);

    try {
      final ref = FirebaseFirestore.instance.collection("schedule/$loginId/${schedule.dateYM}");
      await ref.doc(schedule.id).set(schedule.toFirestore());
    } catch (e) {
      state = state.setShouldHud(false);
      return AppError("エラーが発生しました");
    }

    _updateWidget();

    state = state.setShouldHud(false);
  }

  void _updateWidget() {
    HomeWidget.updateWidget(name: "SmallWidget", androidName: "SmallWidget", iOSName: "SmallWidget");
    HomeWidget.updateWidget(name: "MediumWidget", androidName: "MediumWidget", iOSName: "MediumWidget");
    HomeWidget.updateWidget(name: "LargeWidget", androidName: "LargeWidget", iOSName: "LargeWidget");
  }
}

class _State {
  final bool shouldShowHud;
  final List<Schedule> schedulesInMonth;
  final DateTime focusedDay;
  final DateTime selectedDay;

  String selectedDayText() {
    return DateFormat('yyyy年MM月dd日', "ja_JP").format(selectedDay);
  }

  List<Schedule> schedulesInDay() {
    final dateYMD = DateFormat('yyyy-MM-dd', "ja_JP").format(selectedDay);
    return schedulesInMonth.where((v) => v.dateYMD == dateYMD).toList();
  }

  _State({required this.shouldShowHud, required this.schedulesInMonth, required this.focusedDay, required this.selectedDay});

  static _State init() {
    return _State(shouldShowHud: false, schedulesInMonth: [], focusedDay: DateTime.now(), selectedDay: DateTime.now());
  }

  _State setShouldHud(bool should) {
    return _State(shouldShowHud: should, schedulesInMonth: schedulesInMonth, focusedDay: focusedDay, selectedDay: selectedDay);
  }

  _State setSchedulesInMonth(List<Schedule> items) {
    return _State(shouldShowHud: shouldShowHud, schedulesInMonth: items, focusedDay: focusedDay, selectedDay: selectedDay);
  }

  _State setFocusedDay(DateTime dt) {
    return _State(shouldShowHud: shouldShowHud, schedulesInMonth: schedulesInMonth, focusedDay: dt, selectedDay: selectedDay);
  }

  _State setSelectedDay(DateTime dt) {
    return _State(shouldShowHud: shouldShowHud, schedulesInMonth: schedulesInMonth, focusedDay: focusedDay, selectedDay: dt);
  }
}

final calendarProvider = StateNotifierProvider<_Provider, _State>((_) => _Provider());
