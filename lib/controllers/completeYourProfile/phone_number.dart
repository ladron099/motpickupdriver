import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/upload_image.dart';
import 'package:motopickupdriver/views/completeYourProfile/verify_code.dart';

class VerifyPhoneNumberController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;

  final TextEditingController phone = TextEditingController();
  String indicatif = '+212';

  chnageIndicatif(value) {
    indicatif = value;
  }

  submit(context) async {
    if (phone.text.isEmpty || phone.text.length < 9) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer un numéro de téléphone correct.', 'Ok');
    } else {
      loading.toggle();
      await checkPhoneNumber(indicatif + phone.text).then((value) async {
        print(value);
        if (value == "not-found") {
          userBase!.driver_phone_number = indicatif + phone.text;
          await SessionManager().set('currentUser', userBase);
          
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: indicatif + phone.text,
            timeout: const Duration(seconds: 60),
            verificationCompleted: (phonesAuthCredentials) async {},
            verificationFailed: (FirebaseAuthException e) async {
              loading.toggle();
              if (e.code == 'too-many-requests') {
                showAlertDialogOneButton(
                    context,
                    'Trop de demandes',
                    "Nous avons bloqué toutes les demandes de cet appareil en raison d'une activité inhabituelle, réessayez",
                    "Ok");
              }
            },
            codeSent: (verificationId, resendingToken) async {
              loading.toggle();
              update();
              Get.to(() => VerifyCode(),
                  arguments: [verificationId],
                  transition: Transition.rightToLeft);
            },
            codeAutoRetrievalTimeout: (verificationId) async {},
          );
        } else {
            if(value =='found-in-users'){
               loading.toggle();
        update();
        userBase!.is_verified_account = true;
        userBase!.driver_phone_number = indicatif + phone.text;
        completeUser(userBase!).then((value) {
          Get.to(() => UploadImage(), transition: Transition.rightToLeft);
        });
            }else{
  loading.toggle();
          update();
          showAlertDialogOneButton(
            context,
            'Le numéro de téléphone existe déjà',
            'Veuillez fournir un autre numéro de téléphone',
            'Ok',
          );
            }


        
        }
      });
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) {
      userBase = value;
    });
  }
}
