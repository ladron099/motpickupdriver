// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';

class CongratsController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
    });
    await getData();
    isTrue = true.obs;
    update();
  }
}
