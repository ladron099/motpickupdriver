// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/functions.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/views/auth/verify_number.dart';

class RegisterPageController extends GetxController {
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  RxBool loading = false.obs;
  String indicatif = '+212';

  chnageIndicatif(value) {
    indicatif = value.toString();
  }

  Future<bool> validate(context) {
    loading.toggle();
    update();
    bool valid = true;
    if (phone.text.isEmpty || phone.text.length < 9) {
      showAlertDialogOneButton(
          context,
          "Le numéro de téléphone est incorrect",
          "Veuillez entrer un numéro de téléphone correct pour vérifier votre compte.",
          "Ok");
      valid = false;
      loading.toggle();
      update();
    } else if (!validatePassword(password.text)) {
      showAlertDialogOneButton(
          context,
          "Mot de passe incorrect",
          "Votre mot de passe doit comporter au moins 9 caractères et au moins un chiffre et une lettre.",
          "Ok");
      valid = false;
      loading.toggle();
      update();
    } else if (password.text != confirmPassword.text) {
      showAlertDialogOneButton(
          context,
          "Mot de passe incorrect",
          "S'il vous plaît vérifier votre mot de passe. les deux mots de passe doivent être identiques.",
          "Ok");
      valid = false;
      loading.toggle();
      update();
    }
    return Future.value(valid);
  }

  submit(context) async {
    validate(context).then((value) async {
      if (value) {
        String phoneNumber = indicatif + phone.text;
        //Step One : Check if there's a user in the drivers collection
        await checkPhoneNumber(phoneNumber).then((message) async {
          if (message == "found-in-users" || message == "found-in-driver") { 
            showAlertDialogOneButton(
              context,
              "Numéro de téléphone déjà utilisé!",
              "Veuillez saisir un autre numéro de téléphone, car celui-ci est déjà utilisé par un autre compte, ou essayez de vous connecter.",
              "Ok",
            );
            loading.toggle();
            update();
          } else {
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
              timeout: const Duration(seconds: 5), 
              codeSent: (verificationId, resendingToken) async {
                await SessionManager().set(
                  'tmpUser',
                  TmpUser(
                    email: "$phoneNumber@tmp.xy",
                    phoneNo: phoneNumber,
                    password: password.text,
                    type_account: 'Phone',
                  ),
                );
                Get.to(() => VerfiyNumber(),
                    arguments: verificationId,
                    transition: Transition.rightToLeft);
                loading.toggle();
                update();
              },
              codeAutoRetrievalTimeout: (verificationId) async {},
            );
          }
        });
      }
    });
  }
}
