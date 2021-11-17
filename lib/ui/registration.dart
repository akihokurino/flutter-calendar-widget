import 'package:calendar/provider/calendar.dart';
import 'package:calendar/ui/component/buttons.dart';
import 'package:calendar/ui/component/date_picker_view.dart';
import 'package:calendar/ui/component/dialog.dart';
import 'package:calendar/ui/component/text_field_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:uuid/uuid.dart';

class RegistrationPage extends HookConsumerWidget {
  static Widget init(VoidCallback callback) {
    return RegistrationPage(key: GlobalObjectKey(const Uuid().v4()), callback: callback);
  }

  final VoidCallback callback;

  const RegistrationPage({Key? key, required this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarProvider);
    final calendarAction = ref.read(calendarProvider.notifier);

    final date = useState<DateTime?>(null);
    final name = useState("");

    final now = DateTime.now();

    const double appBarHeight = 50;

    form() {
      return Container(
        margin: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: DatePickerView(
                  label: "日付",
                  initial: now,
                  min: DateTime.utc(now.year - 1, 1, 1),
                  max: DateTime.utc(now.year + 1, 12, 31),
                  onChange: (val) {
                    date.value = val;
                  }),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: TextFieldView(
                  label: "スケジュール名",
                  value: name.value,
                  inputType: TextInputType.text,
                  onSubmit: (val) {
                    name.value = val;
                  }),
            ),
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: ContainedButton(
                text: "登録",
                backgroundColor: ThemeData.dark().primaryColor,
                textColor: ThemeData.dark().textTheme.bodyText1!.color!,
                onClick: () async {
                  final err = await calendarAction.registerSchedule(date.value, name.value);
                  if (err != null) {
                    AppDialog().showErrorAlert(context, err);
                    return;
                  }

                  Navigator.of(context).pop();
                  callback();
                },
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: AppBar(
          title: const Text("スケジュール登録"),
          centerTitle: true,
        ),
      ),
      body: ModalProgressHUD(
          progressIndicator: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ThemeData.dark().textTheme.bodyText1!.color!),
          ),
          opacity: 0.5,
          color: Colors.black,
          child: form(),
          inAsyncCall: calendarState.shouldShowHud),
    );
  }
}
