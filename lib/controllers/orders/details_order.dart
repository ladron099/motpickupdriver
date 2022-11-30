// ignore_for_file: file_names

import 'package:get/get.dart';

class DetailsOrderController extends GetxController {
  RxBool isTrue = false.obs;
  int orderType = 3;

  @override
  void onInit() async {
    super.onInit();

    isTrue = true.obs;
    update();
  }
}
