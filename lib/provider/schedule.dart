import 'package:flutter_calendar_widget/model/errors.dart';
import 'package:flutter_calendar_widget/model/schedule.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  Future<AppError?> fetch() async {
    state = state.setShouldHud(true);

    state = state.setSchedules([]);
    state = state.setShouldHud(false);
  }
}

class _State {
  final bool shouldShowHud;
  final List<Schedule> schedules;

  _State({required this.shouldShowHud, required this.schedules});

  static _State init() {
    return _State(shouldShowHud: false, schedules: []);
  }

  _State setShouldHud(bool should) {
    return _State(shouldShowHud: should, schedules: schedules);
  }

  _State setSchedules(List<Schedule> items) {
    return _State(shouldShowHud: shouldShowHud, schedules: items);
  }
}

final scheduleProvider = StateNotifierProvider<_Provider, _State>((_) => _Provider());
