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

class VerfiyNumberController extends GetxController {
  TextEditingController code = TextEditingController();
  RxBool loading = false.obs, isTrue = true.obs;
  TmpUser? tmpUser;
  int second = 30;
  String message = '', verificationCode = '';

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
    if (code.text.isNotEmpty) {
      loading.toggle();
      update();
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationCode, smsCode: code.text);
        AuthCredential emailCredential = EmailAuthProvider.credential(
          email: tmpUser!.email,
          password: tmpUser!.password,
        );
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;
        user!.linkWithCredential(emailCredential).then((value) async {
          UserBase userBase = UserBase(
            driver_reported_times: 0,
            driver_uid: user.uid,
            driver_full_name: '',
            driver_email: tmpUser!.email,
            driver_sexe: '',
            driver_type_auth: 'Phone',
            driver_date_naissance: '',
            driver_phone_number: tmpUser!.phoneNo,
            driver_profile_picture:
                "https://firebasestorage.googleapis.com/v0/b/motopickup-353120.appspot.com/o/user-images%2Favatar-1.jpeg?alt=media&token=e5a7eff1-1265-42ed-81b1-30a7e56712da",
            driver_registration_date:
                DateFormat("dd-MM-yyyy HH:mm", "Fr_fr").format(DateTime.now()),
            driver_last_login_date:
                DateFormat("dd-MM-yyyy HH:mm", "Fr_fr").format(DateTime.now()),
            driver_current_city: '',
            driver_latitude: 0,
            driver_longitude: 0,
            is_deleted_account: false,
            is_activated_account: false,
            is_verified_account: false,
            is_blacklisted_account: false,
            is_online: false,
            is_on_order: false,
            is_password_change: false,
            is_driver: 0,
            driver_cancelled_delivery: 0,
            driver_succeded_delivery: 0,
            driver_planned_delivery: 0,
            driver_cancelled_trip: 0,
            driver_succeded_trip: 0,
            driver_planned_trip: 0,
            driver_stars_mean: 0,
            driver_note: 0,
            driver_motocylces: [],
            driver_identity_card_number: '',
            driver_identity_card_picture: '',
            driver_identity_card_expiration_date: '',
            driver_driving_licence_number: '',
            driver_driving_licence_picture: '',
            driver_driving_licence_expiration_date: '',
            driver_order_total_amount: '',
            driver_anthropometrique: '',
            driver_total_orders: 0, 
            driver_total_paid: 0,
          );
          GetStorage().write('isLoggedIn', true);
          await SessionManager().set('currentUser', userBase);
          await createUser(userBase).then(
            (value) async {
          await updateFcm();
              Get.offAll(() => CompleteProfile());
            },
          );
        });
      } catch (e) {
        print(e);
        loading.toggle();
        update();
        showAlertDialogOneButton(
            context, "Code requis", "Veuillez entrer le bon code.", "Ok");
      }
    } else {
      showAlertDialogOneButton(
          context, "Code requis", "Veuillez entrer le code reçu", "Ok");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    tmpUser = TmpUser.fromJson(await SessionManager().get('tmpUser'));
    verificationCode = Get.arguments;
    isTrue.toggle();
    startTimer();
    update();
  }
}
