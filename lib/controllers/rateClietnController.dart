import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/order.dart';
import 'package:motopickupdriver/views/home_page.dart';

class RateClientController extends GetxController {
  int rating_stars = 0;
  TextEditingController inputController = TextEditingController();
  TextEditingController reportInputController = TextEditingController();
  Order? order;
  String order_id = "";
  String image = "";
  String fullname = "";
  int client_stars = 0;

  updateRating(index) {
    rating_stars = index;
    update();
  }

  getClientData() async {
  

    var docSnapshot =
      await FirebaseFirestore.instance.collection('orders').doc(order_id).get();
        if (docSnapshot.exists) {
    Map<String, dynamic>? data = docSnapshot.data();
    fullname= data!['user']['user_name'];
    image= data!['user']['user_photo'];
    update();
  }
  
 
  }

  sendFeedBack() async {
    await FirebaseFirestore.instance.collection('orders').doc(order_id).update({
      "comment_about_customer": inputController.text,
      "driver_given_stars": rating_stars
    });
    Get.offAll(() => HomePage(), transition: Transition.leftToRight);
  }

  reportDriver() async {
    await FirebaseFirestore.instance.collection('orders').doc(order_id).update({
      "report_reason_driver": reportInputController.text,
      "is_reported_by_driver": true
    });
  }

  @override
  onInit() async {
    // TODO: implement onInit
    super.onInit();
    order_id = await SessionManager().get("order_id"); 
    getClientData();
    order = Get.arguments[0];
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    inputController.clear();
    rating_stars = 0;
  }
}
