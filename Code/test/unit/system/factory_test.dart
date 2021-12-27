import 'package:badger_group_up/src/system/database.dart';
import 'package:badger_group_up/src/system/group_manager/group_manager.dart';
import 'package:badger_group_up/src/system/shared_values.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:badger_group_up/src/widgets/time_picker_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../database.mocks.dart';

void main() {
  group('Time picker', () {
    setUp(() {

    });

    test('Email Missing', () async {
      var w = TimePickerFactory.buildTimePicker(DateTime.now(), (){});
      expect(w,isNotNull);
    });
  });
}