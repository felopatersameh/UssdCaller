import 'package:hive/hive.dart';

part 'call_entry.g.dart';

@HiveType(typeId: 0)
class CallEntry extends HiveObject {
  @HiveField(0)
  String number;

  @HiveField(1)
  bool isCalled;

  @HiveField(2)
  bool shouldTryLater;

  CallEntry({
    required this.number,
    this.isCalled = false,
    this.shouldTryLater = false,
  });

  CallEntry copyWith({String? number, bool? isCalled, bool? shouldTryLater}) {
    return CallEntry(
      number: number ?? this.number,
      isCalled: isCalled ?? this.isCalled,
      shouldTryLater: shouldTryLater ?? this.shouldTryLater,
    );
  }
}
