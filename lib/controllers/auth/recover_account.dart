// ignore_for_file: file_names

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/complete_profile.dart';
import 'package:motopickupdriver/views/congrats_page.dart';
import 'package:motopickupdriver/views/home_page.dart';

class RecoverAccountController extends GetxController {
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
        await FirebaseAuth.instance.currentUser!.updatePhoneNumber(credential);
        User? user = FirebaseAuth.instance.currentUser;
        await getUser(user!.uid).then((value) async {
          UserBase userBase = value;
          userBase.driver_phone_number = tmpUser!.phoneNo;
          userBase.driver_last_login_date =
              DateFormat("dd-MM-yyyy HH:mm", "Fr_fr").format(DateTime.now());
          completeUser(userBase).then((value) async {
            GetStorage().write('isLoggedIn', true);
            await SessionManager().set('currentUser', userBase);
            
              updateFcm();
            if (userBase.is_verified_account == false) {
              await Get.offAll(() => CompleteProfile(),
                  transition: Transition.rightToLeft);
            }
            if (userBase.is_verified_account == true) {
              if (userBase.is_activated_account == false) {
                await Get.offAll(() => Congrats(),
                    transition: Transition.rightToLeft);
              } else {
                await Get.offAll(() => const HomePage(),
                    transition: Transition.rightToLeft);
              }
            }
            loading.toggle();
            update();
          });
        });
      } on FirebaseAuthException catch (e) {
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
