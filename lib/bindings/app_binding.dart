import 'package:get/get.dart';
import 'package:glitter_launcher/controllers/app_controller.dart';
import 'package:glitter_launcher/database/database.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppDatabase());
    Get.put(AppController());
  }
}
// commit from octodroid clone app