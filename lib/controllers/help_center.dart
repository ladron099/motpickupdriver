// ignore_for_file: file_names

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/emergency.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';

class HelpCenterController extends GetxController {
  UserBase? userBase;
  RxBool loading = false.obs;
  Future shareMyLocation() async {
    loading.toggle();
    update();
    handlerPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Emergency emergency = Emergency(
        user: userBase!.driver_uid,
        latitude: position.latitude,
        longitude: position.longitude,
        city: placemarks.first.locality!,
        phone: userBase!.driver_phone_number);
    createEmergency(emergency);
    loading.toggle();
    update();
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
