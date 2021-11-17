import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Schedule {
  final String id;
  final String dateYM;
  final String dateYMD;
  final String name;
  final int createdAtTimestamnp;

  Schedule({required this.id, required this.dateYM, required this.dateYMD, required this.name, required this.createdAtTimestamnp});

  static Schedule create(DateTime date, String name) {
    final dateYM = DateFormat('yyyy-MM', "ja_JP").format(date);
    final dateYMD = DateFormat('yyyy-MM-dd', "ja_JP").format(date);
    final id = const Uuid().v4();

    return Schedule(id: id, dateYM: dateYM, dateYMD: dateYMD, name: name, createdAtTimestamnp: DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic> toFirestore() {
    return {"id": id, "dateYM": dateYM, "dateYMD": dateYMD, "name": name, "createdAtTimestamp": createdAtTimestamnp};
  }

  DateTime date() {
    return DateTime.parse(dateYMD);
  }

  String dateDisplayText() {
    return DateFormat('MM月dd日', "ja_JP").format(date());
  }

  static Schedule fromFirestore(Map<String, dynamic> data) {
    return Schedule(
        id: data["id"],
        dateYM: data["dateYM"],
        dateYMD: data["dateYMD"],
        name: data["name"],
        createdAtTimestamnp: data["createdAtTimestamp"]);
  }
}
