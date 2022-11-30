// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/ListItems.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/phone_number.dart';
import 'package:motopickupdriver/views/completeYourProfile/upload_image.dart';

class CompleteProfileController extends GetxController {
  RxBool loading = false.obs;
  RxBool isTrue = false.obs;
  bool shown=true;
  UserBase? userBase;
  TmpUser? tmpUser;
  final TextEditingController fullname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController cni = TextEditingController();
  String birthday = "Entrez votre date de naissance";
  bool isValid = false;
  int? initialData;
  var selected;
  List? selectedList;

  List<DropdownMenuItem<ListItem>>? dropdownSexeItems;
  ListItem? sexe;
  final List<ListItem> sexeItems = [
    ListItem("-", "Sélectionnez votre sexe"),
    ListItem("male", "Homme"),
    ListItem("female", "Femme"),
  ];

  dropDownMenuChange(value) {
    sexe = value;
  }

  cityPickerChange(value) {
    if (value != null) {
      selected = value['name'].toString();
      initialData = value['key'];
    } else {
      selected = null;
    }
  }

  Future<bool> validate(context) async {
    if (fullname.text.isEmpty ||
        email.text.isEmpty ||
        birthday == "Entrez votre date de naissance" ||
        sexe!.value == '-' ||
        selected == null ||
        cni.text.isEmpty) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes les données requises.', 'Ok');
      isValid = false;
    }
    else if(!EmailValidator.validate(email.text)){
 showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes un email valide.', 'Ok');
      isValid = false;
    }
     else {
      isValid = true;
    }
    return isValid;
  }

  submit(context) {
    validate(context).then((value) async {
      if (value) {
        TmpUser tmpUser =
            TmpUser.fromJson(await SessionManager().get('tmpUser'));
        loading.toggle();
        update();
        userBase!.driver_full_name = fullname.text;
        userBase!.driver_email = email.text.toLowerCase();
        userBase!.driver_date_naissance = birthday;
        userBase!.driver_identity_card_number = cni.text;
        userBase!.driver_current_city = selected;
        userBase!.driver_sexe = sexe!.value;
      if(userBase!.driver_type_auth=="Phone"){
          AuthCredential emailCredential = EmailAuthProvider.credential(
          email: tmpUser.email,
          password: tmpUser.password,
        );
        await FirebaseAuth.instance.currentUser!
            .reauthenticateWithCredential(emailCredential)
            .then((value) async {
          AuthCredential credential = EmailAuthProvider.credential(
            email: email.text,
            password: tmpUser.password,
          );
          await FirebaseAuth.instance.currentUser?.unlink('password');
          await FirebaseAuth.instance.currentUser!
              .linkWithCredential(credential);
          tmpUser.email = email.text.toLowerCase();
          await SessionManager().set('tmpUser', tmpUser);
          await SessionManager().set('currentUser', userBase);
          completeUser(userBase!).then((value) {
            
              updateFcm();
            loading.toggle();
            update();
            Get.to(() => UploadImage(), transition: Transition.rightToLeft);
          });
        });
      }
         else{
           await SessionManager().set('currentUser', userBase);
          completeUser(userBase!).then((value) {
            
              updateFcm();
            loading.toggle();
            update();
            Get.to(() => VerifyPhoneNumber(), transition: Transition.rightToLeft);
          });
         }
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      fullname.text = value!.driver_full_name;
      userBase!.driver_type_auth == 'Phone'
          ? email.text = ''
          : email.text = value.driver_email;
      userBase!.driver_type_auth == 'Phone'
          ? shown = true
          :shown= false;
    });
    tmpUser = TmpUser.fromJson(await SessionManager().get('tmpUser'));
    dropdownSexeItems = buildDropDownMenuItems(sexeItems);
    sexe = dropdownSexeItems![0].value;
    isTrue.toggle();
    update();
  }
}
