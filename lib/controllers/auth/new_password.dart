// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';

class NewPasswordController extends GetxController {
  RxBool loading = false.obs;
  TmpUser? tmpUser;
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmePasswod = TextEditingController();

  validate(context) {
    print(FirebaseAuth.instance.currentUser);
  }

  submit(context) async {
    validate(context);
  }

  @override
  void onInit() async {
    super.onInit();
    tmpUser = TmpUser.fromJson(await SessionManager().get('tmpUser'));
  }
}
