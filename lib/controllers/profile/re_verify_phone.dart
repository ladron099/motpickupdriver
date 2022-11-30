import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';

class ReVerifyPhoneController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;
  String phoneNumber = '';
  int second = 30;
  String message = '', verificationCode = '';
  TextEditingController code = TextEditingController();
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

  reSendCode(context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (phonesAuthCredentials) async {},
      verificationFailed: (FirebaseAuthException e) async {
        if (e.code == 'too-many-requests') {}
      },
      codeSent: (verificationId, resendingToken) async {
        verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        code.text = verificationId;
      },
    );
    second = 30;
    myDuration = const Duration(seconds: 30);
    message = "";
    code.clear();
    startTimer();
    update();
  }

  submit(context) async {
    if (code.text.isEmpty) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer le code de vérification.', 'Ok');
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationCode, smsCode: code.text);
      try {
        loading.toggle();
        update();
        FirebaseAuth.instance.currentUser!
            .updatePhoneNumber(credential)
            .then((value) {
          userBase!.driver_phone_number = phoneNumber;
          completeUser(userBase!).then((value) {
            Get.offAll(() => ProfilePage(), transition: Transition.leftToRight);
          });
        });
      } catch (e) {
        showAlertDialogOneButton(
            context,
            'Le code de vérification expire',
            'Le code SMS a expiré. Veuillez renvoyer le code de vérification pour réessayer.',
            'Ok');

        update();
      }
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      phoneNumber = Get.arguments[1];
      verificationCode = Get.arguments[0];
      startTimer();
      update();
    });
  }
}
