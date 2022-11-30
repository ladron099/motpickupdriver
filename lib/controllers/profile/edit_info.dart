// ignore_for_file: avoid_print

import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:motopickupdriver/utils/models/ListItems.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/navigations.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';

class EditInfoController extends GetxController {
  UserBase? userBase;

  final TextEditingController fullname = TextEditingController();
  final TextEditingController email = TextEditingController();
  bool shown=true;
  final TextEditingController cni = TextEditingController();
  String birthday = "Entrez votre date de naissance";
  bool isValid = false;
  RxBool isTrue = false.obs;
  String message = " ";

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

  birthdayChange(value) {
    birthday = DateFormat('d-MM-yyyy').format(value).toString();
  }

  Future<bool> validate() async {
    if (fullname.text.isEmpty ||
        email.text.isEmpty ||
        cni.text.isEmpty ||
        birthday == "Entrez votre date de naissance" ||
        sexe!.value == '-') {
      isValid = false;
      message = "Veuillez entrer toutes les données ci-dessus";
      update();
    }
     else if(!EmailValidator.validate(email.text)){
    message = "Veuillez entrer un email valide";
      isValid = false;
    }
    
     else {
      isValid = true;
    }
    return isValid;
  }

  Future submit(context) async {
    validate().then((value) async {
      if (value) {
        isTrue.toggle();
        update();
        userBase!.driver_full_name = fullname.text.trim();
        userBase!.driver_email = email.text.trim();

        userBase!.driver_date_naissance = birthday;
        userBase!.driver_sexe = sexe!.value;
        await completeUser(userBase!).then((value) async {
          await saveCurrentUser(userBase!).then((value) => print(value));
          goBackOff(ProfilePage());
          /*  showAchievementView(context, 'Informations mises à jour avec succès',
              'Vos informations ont été mises à jour avec succès.'); */
          Get.delete<EditInfoController>();
        });
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      fullname.text = userBase!.driver_full_name;
      email.text = userBase!.driver_email;
      birthday = userBase!.driver_date_naissance;
      dropdownSexeItems = buildDropDownMenuItems(sexeItems);
      userBase!.driver_sexe == 'male'
          ? sexe = dropdownSexeItems![1].value
          : sexe = dropdownSexeItems![2].value;
      cni.text = userBase!.driver_identity_card_number;
      userBase!.driver_type_auth == 'Phone'
          ? shown = true
          :shown= false;
      isTrue.toggle();
      update();
    });
  }
}
