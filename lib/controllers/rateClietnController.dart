import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/models/order.dart';
import 'package:motopickupdriver/views/home_page.dart';

class RateClientController extends GetxController {
  int rating_stars = 0;
  TextEditingController inputController = TextEditingController();
  TextEditingController reportInputController = TextEditingController();
  // Order? order;
  String order_id = "";
  String image = "";
  String fullname = "";
  String type = "";
  String customer_uid = "";
  String driver_uid = "";
  double price = 0;
  // ignore: non_constant_identifier_names
  double client_stars = 0;

  updateRating(index) {
    rating_stars = index;
    update();
  }

  getClientData() async {
    var docSnapshot2 = await FirebaseFirestore.instance
        .collection('orders')
        .doc(order_id)
        .get();
    if (docSnapshot2.exists) {
      Map<String, dynamic>? data = docSnapshot2.data();
      fullname = data!['user']['customer_full_name'];
      image = data['user']['customer_picture'];
      type = data['order_type'].toString();
      customer_uid = data['customer_uid'];
      driver_uid = data['driver_uid'];
      update();
    }
    var docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(customer_uid)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      client_stars = data!['customer_note'] / data['customer_total_orders'];
      client_stars = double.parse(client_stars.toStringAsFixed(1));
      update();
    }
  }

  sendFeedBack() async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driver_uid)
        .update({
      "driver_total_paid": FieldValue.increment(price),
    });
    await FirebaseFirestore.instance
        .collection('users')
        .doc(customer_uid)
        .update({
      "customer_total_paid": FieldValue.increment(price),
    });

    await FirebaseFirestore.instance.collection('orders').doc(order_id).update({
      "comment_about_customer": inputController.text,
      "driver_given_stars": rating_stars
    });
    type != "0"
        ? await FirebaseFirestore.instance
            .collection('users')
            .doc(customer_uid)
            .update({
            "customer_note": FieldValue.increment(rating_stars),
            "customer_succeded_trip": FieldValue.increment(1),
            "customer_total_orders": FieldValue.increment(1),
          })
        : await FirebaseFirestore.instance
            .collection('users')
            .doc(customer_uid)
            .update({
            "customer_note": FieldValue.increment(rating_stars),
            "customer_succeded_delivery": FieldValue.increment(1),
            "customer_total_orders": FieldValue.increment(1),
          });
    // type!="0"?
    //   await FirebaseFirestore.instance
    //       .collection('drivers')
    //       .doc(driver_uid)
    //       .update({
    //     "driver_succeded_trip": FieldValue.increment(1),
    //   }):await FirebaseFirestore.instance
    //       .collection('drivers')
    //       .doc(driver_uid)
    //       .update({
    //     "driver_succeded_delivery": FieldValue.increment(1),
    //   });
    
    Get.offAll(() => HomePage(), transition: Transition.leftToRight);
  }

  reportClient() async {
    await FirebaseFirestore.instance.collection('orders').doc(order_id).update({
      "report_reason_driver": reportInputController.text,
      "is_reported_by_driver": true
    });
    await FirebaseFirestore.instance
            .collection('users')
            .doc(customer_uid)
            .update({
            "customer_reported_times": FieldValue.increment(1),
          });
  }

  @override
  onInit() async {
    // TODO: implement onInit
    super.onInit();
    order_id = await SessionManager().get("order_id");
    getClientData();
    price = await SessionManager().get("distance") / 1000 < 6 ? 10 : 15;
    // order = Get.arguments[0];
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    inputController.clear();
    rating_stars = 0;
  }
}
