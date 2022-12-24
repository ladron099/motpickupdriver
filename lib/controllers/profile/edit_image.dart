// ignore_for_file: file_names

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';

class EditImageController extends GetxController {
  UserBase? userBase;
  RxBool loading = false.obs;
  XFile? file;
  File? image;

  selectImage() async {
   try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      image = File(file!.path);
      update();
    }
   } catch (e) {
     print(e);
   }
  }

  uploadImage() async {
    loading.toggle();
    update();
    FirebaseStorage.instance
        .ref('user-images/${file!.name}')
        .putFile(image!)
        .then((p0) {
      p0.ref.getDownloadURL().then((value) async {
        userBase!.driver_profile_picture = value;
        userBase!.is_activated_account = true;
        userBase!.is_verified_account = true;
        await saveCurrentUser(userBase!);
        completeUser(userBase!).then((value) {
          Get.offAll(() => ProfilePage(), transition: Transition.leftToRight);
        });
      });
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
      update();
    });
  }
}
