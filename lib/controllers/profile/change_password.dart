// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/controllers/profile/edit_info.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/navigations.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';

class ChangePasswordController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs, loading = false.obs;

  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmePasswod = TextEditingController();

  Future<bool> validate(context) async {
    bool isValid = true;
    loading.toggle();
    if (currentPassword.text.isEmpty ||
        newPassword.text.isEmpty ||
        confirmePasswod.text.isEmpty) {
      showAlertDialogOneButton(context, "Données requises",
          "Veuillez entrer toutes les données requises.", "ok");
      loading.toggle();
      update();
      isValid = false;
    } else if (currentPassword.text == newPassword.text) {
      showAlertDialogOneButton(
          context,
          "Erreur",
          "Le nouveau mot de passe doit être différent du mot de passe actuel.",
          "ok");
      loading.toggle();
      update();
      isValid = false;
    } else if (newPassword.text != confirmePasswod.text) {
      showAlertDialogOneButton(
          context,
          "Erreur",
          "Le mot de passe de confirmation doit être identique au nouveau mot de passe.",
          "ok");
      loading.toggle();
      update();
      isValid = false;
    }
    return Future.value(isValid);
  }

  submit(context) async {
    await validate(context).then((value) async {
      if (value) {
        try {
          User user = FirebaseAuth.instance.currentUser!;
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: userBase!.driver_email,
            password: currentPassword.text,
          );

          user.updatePassword(newPassword.text).then((_) {
            goBackOff(ProfilePage());
            Get.delete<EditInfoController>();
          }).catchError((error) {
            showAlertDialogOneButton(
                context,
                "Mot de passe incorrect",
                "Mot de passe erroné, veuillez vérifier votre mot de passe.",
                "Ok");
          });
        } on FirebaseAuthException catch (e) {
          loading.toggle();
          update();
          if (e.code == 'user-not-found') {
            showAlertDialogOneButton(
                context,
                "Utilisateur non trouvé",
                "Il n'y a pas d'utilisateur avec ce numéro de téléphone.",
                "Ok");
            loading.toggle();
            update();
          } else if (e.code == 'wrong-password') {
            showAlertDialogOneButton(
                context,
                "Mot de passe incorrect",
                "Mot de passe erroné, veuillez vérifier votre mot de passe.",
                "Ok");
          }
        }
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      isTrue.toggle();
      update();
    });
  }
}
