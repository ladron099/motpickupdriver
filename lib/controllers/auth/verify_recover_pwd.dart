// ignore_for_file: file_names, unused_local_variable

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/views/auth/new_password.dart';

class VerifyRecoverPwdController extends GetxController {
  TextEditingController code = TextEditingController();
  RxBool loading = false.obs, isTrue = true.obs;
  TmpUser? tmpUser;
  int second = 30;
  String message = '', verificationCode = '', phone = '';

  Timer? countdownTimer;
  Duration myDuration = const Duration(seconds: 30);
  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = myDuration.inSeconds - reduceSecondsBy;
    second = seconds;
    if (seconds <= 0) {
      countdownTimer!.cancel();
    } else {
      myDuration = Duration(seconds: seconds);
    }
    update();
  }

  reSendCode() async {
    code.clear();
    update();
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: tmpUser!.phoneNo,
      verificationCompleted: (phonesAuthCredentials) async {},
      verificationFailed: (verificationFailed) async {},
      codeSent: (verificationId, resendingToken) async {
        verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
    second = 30;
    myDuration = const Duration(seconds: 30);
    startTimer();
    update();
  }

  submit(context) async {
    if (code.text.isNotEmpty && code.text.length == 6) {
      loading.toggle();
      update();
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationCode, smsCode: code.text);
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: FirebaseAuth.instance.currentUser!.email.toString());
        Get.to(() => NewPassword(), transition: Transition.rightToLeft);
        code.clear();
        loading.toggle();
        update();
      } on FirebaseAuthException catch (e) {
        if (e.code == "invalid-verification-code") {
          showAlertDialogOneButton(
              context,
              "Le code est incorrect",
              "Le code que vous avez entré est incorrect, veuillez vérifier le SMS que nous vous envoyons.",
              "Ok");
        }
        if (e.code == "session-expired") {
          showAlertDialogOneButton(
              context,
              "Code SMS a expiré",
              "Le code SMS a expiré. Veuillez renvoyer le code de vérification pour réessayer.",
              "Ok");
        }
        loading.toggle();
        update();
      }
    } else {
      showAlertDialogOneButton(
          context, "Code requis", "Veuillez entrer le code reçu", "Ok");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    verificationCode = Get.arguments[0];
    tmpUser = TmpUser.fromJson(await SessionManager().get('tmpUser'));
    isTrue.toggle();
    startTimer();
    update();
  }
}
