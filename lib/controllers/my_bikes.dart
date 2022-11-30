// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';

class MyBikesController extends GetxController {
  UserBase? userBase;
  List<dynamic>? listMoto;
  RxBool isTrue = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      listMoto = userBase!.driver_motocylces;
      isTrue = true.obs;
      update();
    });
  }
}
