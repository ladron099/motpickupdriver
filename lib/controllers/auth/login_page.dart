// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:motopickupdriver/views/completeYourProfile/complete_profile.dart';
import 'package:motopickupdriver/views/congrats_page.dart';
import 'package:motopickupdriver/views/home_page.dart';

import '../../utils/services.dart';

class LoginPageController extends GetxController {
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  String indicatif = '+212';
  RxBool loading = false.obs;

  chnageIndicatif(value) {
    indicatif = value.toString();
  }

  Future<bool> validate(context) async {
    bool isValid = true;
    loading.toggle();
    update();
    if (phone.text.isEmpty || phone.text.length < 9) {
      showAlertDialogOneButton(
          context,
          "Le numéro de téléphone est incorrect",
          "Veuillez entrer un numéro de téléphone correct pour vérifier votre compte.",
          "Ok");
      isValid = false;
      loading.toggle();
      update();
    } else if (password.text.isEmpty || password.text.length < 9) {
      showAlertDialogOneButton(
          context,
          "Erreur de mot de passe",
          "Veuillez entrer un mot de passe valide, doit contenir plus de 9 caractères.",
          "Ok");
      isValid = false;
      loading.toggle();
      update();
    }
    return Future.value(isValid);
  }
Future<String> userHasPhone(phone) async {
  String provider = '';
  await FirebaseFirestore.instance
      .collection('users')
      .where('customer_phone_number', isEqualTo: phone)
      .where('is_deleted_account', isEqualTo: false)
      .snapshots()
      .first
      .then((value) async {
        List<DocumentSnapshot> documentSnapshot = value.docs;
        if (value.size != 0) provider = documentSnapshot[0]['customer_auth_type'];
      });

  await FirebaseFirestore.instance
      .collection('drivers')
      .where('driver_phone_number', isEqualTo: phone)
      .where('is_deleted_account', isEqualTo: false)
      .snapshots()
      .first
      .then((value) async {
         List<DocumentSnapshot> documentSnapshot = value.docs;
        if (value.size != 0)   provider = documentSnapshot[0]['driver_auth_type'];
      });

  return provider;
}
  submit(context) async {
    validate(context).then((value) async {
      if (value) {

        String phoneNo=indicatif + phone.text;
        await userHasPhone( phoneNo).then((value){
            if(value !="Phone" && value !=""){
            return showAlertDialogOneButton(
                context,
                "L'utilisateur existe déjà",
                "Il existe déjà un compte avec cet e-mail, veuillez essayer de vous connecter avec $value",
      "Ok");
             
            }else{
                 loginWithPhone(indicatif + phone.text).then((value) async {
          try {
            UserCredential authResult = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: value, password: password.text);
            User? user = authResult.user;
            await getUser(user!.uid).then((value) async {
              value.driver_last_login_date =
                  DateFormat("dd-MM-yyyy HH:mm", "Fr_fr")
                      .format(DateTime.now());
              UserBase userBase = value;
              await completeUser(userBase);
              await SessionManager().set(
                'tmpUser',
                TmpUser(
                  email: userBase.driver_email,
                  phoneNo: userBase.driver_phone_number,
                  password: password.text,
                  type_account: '',
                ),
              );
              await GetStorage().write('isLoggedIn', true);
              await SessionManager().set('currentUser', userBase);
              updateFcm();
              // Get.offAll(() => const HomePage(),
              //     transition: Transition.rightToLeft);
               if (value.is_verified_account == false) {
                Get.offAll(() => CompleteProfile(),
                    transition: Transition.rightToLeft);
              }
              if (value.is_verified_account == true) {
                if (value.is_activated_account == false) {
                  Get.offAll(() => Congrats(),
                      transition: Transition.rightToLeft);
                } else {
                  Get.offAll(() => const HomePage(),
                      transition: Transition.rightToLeft);
                }
              } 
            });
          } on FirebaseAuthException catch (e) {
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
              loading.toggle();
              update();
            }
          }
        });
    
            }
        });
       }
    });
  }
}
