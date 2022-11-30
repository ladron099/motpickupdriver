// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';

class MyCommandController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs;

  bool isActiveOne = false, isActiveTwo = true;
  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value; 
      isTrue = true.obs;
      update();
    });
  }
}
