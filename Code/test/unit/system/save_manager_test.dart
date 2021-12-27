import 'package:badger_group_up/src/system/save_manager.dart';
import 'package:badger_group_up/src/system/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Save Manager', ()
  {
    setUp((){
      SaveManager.instance.loadPrefs();
    });

    test('Load string Missing fail', () async {
      var s = await SaveManager.instance.loadString("Does not exists");
      expect(s,isNull);
    });
    test('Load string Success', () async {
      String val = "HI";
      await SaveManager.instance.saveString("testString", val);
      var s = await SaveManager.instance.loadString("testString");
      expect(s,val);
    });
    test('Save and Load Bool Success', () async {
      var val = true;
      await SaveManager.instance.saveBool("testBool", val);
      var s = await SaveManager.instance.loadBool("testBool");
      expect(s,val);
    });
    test('Load Missing Bool Success', () async {
      var s = await SaveManager.instance.loadBool("NoBool",def: false);
      expect(s,false);
    });

  });

}