// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/views/auth/verify_recover_pwd.dart';

class ForgotPasswordController extends GetxController {
  RxBool loading = false.obs;

  final TextEditingController phone = TextEditingController();
  String indicatif = '+212';

  chnageIndicatif(value) {
    indicatif = value;
  }

  Future<bool> validate(context) async {
    bool isValid = true;
    loading.toggle();
    update();
    if (phone.text.isEmpty || phone.text.length < 9) {
      showAlertDialogOneButton(
        context,
        "Numéro de téléphone incorrect",
        "Veuillez entrer un numéro de téléphone correct pour récupérer votre mot de passe.",
        "Ok",
      );
      loading.toggle();
      update();
      isValid = false;
    }

    return isValid;
  }

  submit(context) async {
    await validate(context).then((value) async {
      if (value) {
        isUserExist(indicatif + phone.text).then((value) async {
          if (value) {
            try {
              await FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: indicatif + phone.text,
                verificationCompleted: (phonesAuthCredentials) async {},
                verificationFailed: (FirebaseAuthException e) async {
                  loading.toggle();
                  update();
                  if (e.code == 'too-many-requests') {
                    showAlertDialogOneButton(
                      context,
                      "Réessayez plus tard",
                      "Nous avons bloqué toutes les demandes de cet appareil en raison d'une activité inhabituelle",
                      "Ok",
                    );
                  }
                },
                codeSent: (verificationId, resendingToken) async {
                  TmpUser tmpUser = TmpUser(
                    email: '',
                    phoneNo: indicatif + phone.text,
                    password: '',
                    type_account: '',
                  );
                  await SessionManager().set('tmpUser', tmpUser);
                  Get.to(() => VerifyRecoverPwd(), arguments: [verificationId]);
                  loading.toggle();
                  update();
                },
                codeAutoRetrievalTimeout: (verificationId) async {},
              );
            } on FirebaseAuthException catch (e) { 
              loading.toggle();
              update();
            }
          } else {
            showAlertDialogOneButton(
              context,
              "L'utilisateur n'existe pas",
              "Il n'y a aucun utilisateur avec ce numéro de téléphone. veuillez entrer un numéro de téléphone correct.",
              "Ok",
            );
            loading.toggle();
            update();
          }
        });
      }
    });
  }
}
