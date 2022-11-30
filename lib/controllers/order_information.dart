// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/services.dart';

import 'home_page.dart';

class OrderInformationController extends GetxController {
  UserBase? userBase;
  RxBool isTrue = false.obs;
  String? orderId;
  int startsmean=0;
  String clientNumber = "";

  HomePageController contrr= Get.put(HomePageController()); 

  bool isActiveOne = false, isActiveTwo = true;
String time="";

  getTime()async{
    String finallong=  "-5.571775585412979";
    String finallat = "33.85889792239378";
    String oringinlong = "-6.571775585412979";
    String oringinlat = "23.85889792239378";
Dio dio = new Dio();
var response=await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=$mapKey");

 
    update();
  }


  getClientData()async{
    String id="";
  var docSnapshot =
      await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
        if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    id= data!['customer_uid']; 
    update();
        }
    docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(id).get();
        if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    clientNumber= data!['customer_phone_number']; 
    startsmean= data['customer_stars_mean']; 
 
    update();
        }




  }
  @override
  void onInit() async {
    super.onInit();
    await getTime();
    await getUserFromMemory().then((value) async {
      userBase = value;
      orderId = Get.arguments[0];
      await getClientData();
      isTrue = true.obs;
      update();
    });
  }
}
