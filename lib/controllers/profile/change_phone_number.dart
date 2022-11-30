import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/profile/re_verify_phone.dart';

class ChangePhoneNumberController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;

  final TextEditingController phone = TextEditingController();
  String indicatif = '+212';

  chnageIndicatif(value) {
    indicatif = value;
  }

  submit(context) async {
    /* if (phone.text.isEmpty || phone.text.length < 9) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer un numéro de téléphone correct.', 'Ok');
    } else if (indicatif + phone.text == userBase!.driver_phone_number) {
      showAlertDialogOneButton(context, 'Changer votre numéro de téléphone',
          'Vous avez entré votre numéro de téléphone actuel.', 'Ok');
    } else { */
    loading.toggle();
    userBase!.driver_phone_number = indicatif + phone.text;
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: indicatif + phone.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (phonesAuthCredentials) async {},
      verificationFailed: (FirebaseAuthException e) async {
        loading.toggle();
        if (e.code == 'too-many-requests') {
          /* showValidationDialog(context, 'Trop de demandes',
                    "Nous avons bloqué toutes les demandes de cet appareil en raison d'une activité inhabituelle, réessayez"); */
        }
      },
      codeSent: (verificationId, resendingToken) async {
        loading.toggle();
        update();
        Get.to(() => ReVerifyPhone(),
            arguments: [verificationId, indicatif + phone.text],
            transition: Transition.rightToLeft);
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
    //}
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) {
      userBase = value;
    });
  }
}
