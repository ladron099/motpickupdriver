import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/models/ListItems.dart';
import 'package:motopickupdriver/utils/models/config-params.dart';
import 'package:motopickupdriver/utils/models/moto.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/adding_photo_moto.dart';

class AddingMotoController extends GetxController {
  RxBool loading = false.obs, isTrue = false.obs;
  UserBase? userBase;
  TextEditingController marque = TextEditingController();
  TextEditingController modele = TextEditingController();
  TextEditingController imma = TextEditingController();
  TextEditingController color = TextEditingController();
  XFile? file;
  File? image;

  List<DropdownMenuItem<ListItem>>? dropdowntypeItems;
  ListItem? type;
  List<ListItem> typeItems = [
    ListItem("-", "Sélectionnez Type"),
  ];
  dropDownMenuChange(value) {
    type = value;
  }

  Future getMoto() async {
    final value = await FirebaseFirestore.instance
        .collection('config')
        .doc('config-params')
        .get();

    MotoType motoTypeT1 = MotoType.fromJson(value.get('T1'));
    MotoType motoTypeT2 = MotoType.fromJson(value.get('T2'));
    MotoType motoTypeT3 = MotoType.fromJson(value.get('T3'));
    typeItems.add(ListItem('T1', motoTypeT1.name));
    typeItems.add(ListItem('T2', motoTypeT2.name));
    typeItems.add(ListItem('T3', motoTypeT3.name));
    update();
  }

  Future<bool> validate(context) {
    bool isValid = true;
    if (marque.text.isEmpty ||
        modele.text.isEmpty ||
        imma.text.isEmpty ||
        color.text.isEmpty ||
        type!.value == '-') {
      showAlertDialogOneButton(context, 'Données requises',
          'Vous devez entrer toutes les données requises.', 'Ok');
      isValid = false;
    }
    return Future.value(isValid);
  }

  submit(context) async {
    await validate(context).then((value) async {
      if (value) {
        loading.toggle();
        update();
        Moto moto = Moto(
          motocycle_brand: marque.text,
          motocycle_model: modele.text,
          motocycle_color: color.text,
          motocycle_type: type!.value,
          motocycle_imm: imma.text,
          motocycle_photo: '',
          motocycle_status: true,
        );
        await SessionManager().set('moto', moto);
        await SessionManager().set('currentUser', userBase);
        
              updateFcm();
        loading.toggle();
        update();
        await Get.to(() => AddingPhotoMoto());
      }
    });
  }

  @override
  void onInit() async {
    super.onInit();
    await getUserFromMemory().then((value) async {
      userBase = value;
    });
    await getMoto();
    dropdowntypeItems = buildDropDownMenuItems(typeItems);
    type = dropdowntypeItems![0].value;
    isTrue.toggle();
    update();
  }
}
