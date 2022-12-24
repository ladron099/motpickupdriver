// ignore_for_file: file_names, deprecated_member_use

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/congrats_page.dart';

class VerifyIdentityController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;
  bool isOpen = false, isCoursier = false, isDriver = false;
  XFile? cardFile, cardLicence;
  String cardExpire = 'Date d’expiration', licenceExpire = "Date d’expiration";
  File? card, licence;

  selectImageCard() async {
    try {
      cardFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (cardFile != null) {
      card = File(cardFile!.path);
      update();
    }
    } catch (e) {
     print(e); 
    }
  }

  selectImageLicence() async {
   try {
      cardLicence = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (cardLicence != null) {
      licence = File(cardLicence!.path);
      update();
    }
   } catch (e) {
     print(e);
   }
  }

  Future<bool> validat(context) async {
    bool isValid = true;
    if (cardExpire == 'Date d’expiration' ||
        licenceExpire == 'Date d’expiration' ||
        cardFile == null ||
        cardLicence == null) {
      isValid = false;
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes les données requises.', 'Ok');
    }
    return isValid;
  }

  submit(context) async {
    if (isCoursier == false && isDriver == false) {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes les données requises.', 'Ok');
    } else {
      loading.toggle();
      update();
      await uploadImage();
      loading.toggle();
      update();
    }
  }

  uploadImage() async {
    await FirebaseStorage.instance
        .ref('user-images/${cardFile!.name}')
        .putFile(card!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) async {
        userBase!.driver_identity_card_picture = value;
        userBase!.driver_identity_card_expiration_date = cardExpire;
      });
    });
    await FirebaseStorage.instance
        .ref('user-images/${cardLicence!.name}')
        .putFile(licence!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) async {
        userBase!.driver_driving_licence_picture = value;
        userBase!.driver_driving_licence_expiration_date = licenceExpire;
      });
    });
    userBase!.is_verified_account = true;
    if (isCoursier == true && isDriver == false) {
      userBase!.is_driver = 1;
    }
    if (isCoursier == false && isDriver == true) {
      userBase!.is_driver = 2;
    }
    if (isCoursier == true && isDriver == true) {
      userBase!.is_driver = 3;
    }
    await saveCurrentUser(userBase!);
    completeUser(userBase!).then((value) {
      Get.offAll(() => Congrats(), transition: Transition.rightToLeft);
      loading.toggle();
      update();
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
    });

    update();
  }
}
