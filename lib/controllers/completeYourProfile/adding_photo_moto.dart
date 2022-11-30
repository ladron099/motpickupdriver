import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/moto.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/verify_identity.dart';

class AddingPhotoMotoController extends GetxController {
  RxBool loading = false.obs;
  UserBase? userBase;
  Moto? moto;
  XFile? file;
  File? image;

  selectImage() async {
    file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      image = File(file!.path);
      update();
    }
  }

  uploadImage(context) async {
    if (file != null) {
      loading.toggle();
      update();
      FirebaseStorage.instance
          .ref('drivers/${file!.name}')
          .putFile(image!)
          .then((p0) {
        p0.ref.getDownloadURL().then((value) async {
          moto!.motocycle_photo = value;
          List bikes = userBase!.driver_motocylces.toList();
          bikes.clear();
          bikes = [
            {
              'motocycle_brand': moto!.motocycle_brand,
              'motocycle_model': moto!.motocycle_model,
              'motocycle_color': moto!.motocycle_color,
              'motocycle_type': moto!.motocycle_type,
              'motocycle_imm': moto!.motocycle_imm,
              'motocycle_photo': value,
              'motocycle_status': true,
            }
          ];
          userBase!.driver_motocylces = bikes;
          await saveCurrentUser(userBase!);
          completeUser(userBase!).then((value) async {
            await Get.to(() => const VerifyIdentity(),
                transition: Transition.rightToLeft);
            loading.toggle();
            update();
          });
        });
      });
    } else {
      showAlertDialogOneButton(context, "Image requise",
          "Veuillez ajouter une nouvelle photo de votre moto", "Ok");
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      moto = Moto.fromJson(await SessionManager().get('moto'));
    });
    update();
  }
}
