import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';

class ProfilePageController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      isTrue.toggle();
      update();
    });
  }
}
