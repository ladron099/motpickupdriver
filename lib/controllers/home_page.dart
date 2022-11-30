// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:motopickupdriver/utils/colors.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';

class HomePageController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs;
  bool status = false;
  String? city;
  double? latitude, longtitude;
  CameraPosition? kGooglePlex;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  BitmapDescriptor? startIcon, endIcon, motoIcon;
  GoogleMapController? mapController;
  bool isOnOrder = false, startCourse = false;
  bool isWithOrder= false;

  String? orderID;

getWithOrder()async{
  
 var docSnapshot =
      await FirebaseFirestore.instance.collection('drivers').doc(userBase!.driver_uid).get();
        if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    isWithOrder= data!['is_on_order']; 
    update(); 
        } 
}


  goOnline() async {
    userBase!.is_online = status;
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(userBase!.driver_uid)
        .update(userBase!.toJson());
  }

  getUserLocation() async {
    motoIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2),
        'assets/images/marker_moto.png');
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    kGooglePlex = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 12,
    );
    latitude = position.latitude;
    longtitude = position.longitude;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude,
        localeIdentifier: "fr_FR");
    city = placemarks.first.locality;
    userBase!.driver_latitude = latitude!;
    userBase!.driver_longitude = longtitude!;
    kGooglePlex = CameraPosition(
      target: LatLng(latitude!, longtitude!),
      zoom: 16,
    );
    markers.add(
      Marker(
        markerId: const MarkerId('id-1'),
        icon: motoIcon!,
        position: LatLng(
          latitude!,
          longtitude!,
        ),
      ),
    );
    update();
  }

  setRoad(startLatitude, startLongtitude, endlatitude, endlongtitude) async {
    startIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2),
        'assets/images/marker_start.png');
    endIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2),
        'assets/images/marker_end.png');
    markers.addAll([
      Marker(
        markerId: const MarkerId('id-2'),
        icon: startIcon!,
        position: LatLng(
          startLatitude,
          startLongtitude,
        ),
      ),
      Marker(
        markerId: const MarkerId('id-3'),
        icon: endIcon!,
        position: LatLng(
          endlatitude,
          endlongtitude,
        ),
      ),
    ]);
    Polyline polyline = await PolylineService().drawPolyline(
      LatLng(
        startLatitude,
        startLongtitude,
      ),
      LatLng(
        endlatitude,
        endlongtitude,
      ),
      primary,
    );
    kGooglePlex = CameraPosition(
      target: LatLng(latitude!, longtitude!),
      zoom: 18,
    );
    Polyline polylineDriver = await PolylineService().drawPolyline(
      LatLng(
        latitude!,
        longtitude!,
      ),
      LatLng(
        startLatitude,
        startLongtitude,
      ),
      Colors.red,
    );
    polylines.clear();
    polylines.addAll([polyline, polylineDriver]);
    update();
    update();
  }

  @override
  void onInit() async {
    super.onInit();
   
    await getCurrentUser().then((value) async {
      userBase = value;
      status = userBase!.is_online;
      await getUserLocation();
    });
      await getWithOrder();
    isTrue.toggle();
    update();
  }
}
