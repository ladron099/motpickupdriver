import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/views/auth/recover_account.dart';

class ChangePhoneNumberNoAuthController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;
  TmpUser? tmpUser;

  final TextEditingController currentPhone = TextEditingController();
  final TextEditingController newPhone = TextEditingController();
  final TextEditingController password = TextEditingController();
  String indicatif = '+212', secondIndicatif = "+212";

  chnageIndicatif(value) {
    indicatif = value.toString();
  }

  chnageSecondIndicatif(value) {
    secondIndicatif = value.toString();
  }

  Future<bool> validation(context) async {
    bool isValid = true;
    loading.toggle();
    update();
    if (currentPhone.text.isEmpty ||
        newPhone.text.isEmpty ||
        password.text.isEmpty) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes les données requises.', 'Ok');
      isValid = false;
      loading.toggle();
      update();
    } else if (currentPhone.text == newPhone.text) {
      showAlertDialogOneButton(
          context,
          'Changer le nouveau numéro de téléphone',
          'Votre nouveau numéro de téléphone doit être différent de votre ancien numéro de téléphone.',
          'Ok');
      isValid = false;
      loading.toggle();
      update();
    }
    return Future.value(isValid);
  }

  submit(context) async {
    await validation(context).then((value) async {
      if (value) {
        await loginWithPhone(indicatif + currentPhone.text).then((email) {
          tmpUser = TmpUser(
            email: email,
            phoneNo: currentPhone.text,
            password: password.text,
            type_account: '',
          );
          checkPhoneNumber(indicatif + newPhone.text).then((value) async {
            if (value == "") {
              try {
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password.text)
                    .then((value) async {
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: indicatif + newPhone.text,
                    verificationCompleted: (phonesAuthCredentials) async {},
                    verificationFailed: (FirebaseAuthException e) async {
                      if (e.code == 'too-many-requests') {
                        showAlertDialogOneButton(
                          context,
                          "Réessayez plus tard",
                          "Nous avons bloqué toutes les demandes de cet appareil en raison d'une activité inhabituelle",
                          "Ok",
                        );
                        loading.toggle();
                        update();
                      }
                    },
                    codeSent: (verificationId, resendingToken) async {
                      tmpUser!.phoneNo = secondIndicatif + newPhone.text;
                      await SessionManager().set('tmpUser', tmpUser);
                      await Get.to(() => RecoverAccount(),
                          arguments: verificationId,
                          transition: Transition.rightToLeft);
                      loading.toggle();
                      update();
                    },
                    codeAutoRetrievalTimeout: (verificationId) async {},
                  );
                });
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  showAlertDialogOneButton(
                      context,
                      "Utilisateur non trouvé",
                      "Il n'y a pas d'utilisateur avec ce numéro de téléphone.",
                      "Ok");
                } else if (e.code == 'wrong-password') {
                  showAlertDialogOneButton(
                      context,
                      "Mot de passe incorrect",
                      "Mot de passe erroné, veuillez vérifier votre mot de passe.",
                      "Ok");
                }
              }
            } else {
              showAlertDialogOneButton(
                  context,
                  'Changer le nouveau numéro de téléphone',
                  'il semble que le nouveau numéro de téléphone soit déjà lié à un utilisateur existant.',
                  'Ok');
            }
          });
        });
      }
    });
  }
}
