// ignore_for_file: must_be_immutable

import 'package:boxicons/boxicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motopickupdriver/components/cards.dart';
import 'package:motopickupdriver/components/drawer.dart';
import 'package:motopickupdriver/controllers/home_page.dart';
import 'package:motopickupdriver/utils/alert_dialog.dart';
import 'package:motopickupdriver/utils/buttons.dart';
import 'package:motopickupdriver/utils/colors.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/typography.dart';
import 'package:motopickupdriver/views/help_center.dart';
import 'package:motopickupdriver/views/rateClient.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var controller = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => willPopScoop(context),
      child: SafeArea(
        child: GetBuilder<HomePageController>(
          init: HomePageController(),
          builder: (value) => Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: scaffold,
            key: _key,
            appBar: !controller.isTrue.value
                ? AppBar(
                    toolbarHeight: 80.h,
                    title: Image.asset(
                      'assets/images/logoMoto_colored.png',
                      height: 50.h,
                    ),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  )
                : AppBar(
                    leading: InkWell(
                      onTap: () {
                        _key.currentState!.openDrawer();
                      },
                      child: Icon(
                        Boxicons.bx_grid_alt,
                        color: primary,
                        size: 35.h,
                      ),
                    ),
                    toolbarHeight: 80.h,
                    title: Image.asset(
                      'assets/images/logoMoto_colored.png',
                      height: 50.h,
                    ),
                    actions: [
                      FlutterSwitch(
                        width: 70.w,
                        height: 40.h,
                        valueFontSize: 15.0,
                        activeColor: primary,
                        toggleSize: 30.0,
                        value: controller.status,
                        borderRadius: 30.0,
                        padding: 5.0,
                        showOnOff: false,
                        onToggle: (val) {
                          controller.status = !controller.status;
                          controller.goOnline();
                          controller.update();
                        },
                      ),
                      15.horizontalSpace,
                    ],
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
            drawer: NavigationDrawerWidget(
              currentUser: controller.userBase,
            ),
            body: !controller.isTrue.value
                ? Center(
                    child: SizedBox(
                      width: 225.w,
                      child: const LoadingIndicator(
                          indicatorType: Indicator.ballScaleMultiple,
                          colors: [primary],
                          strokeWidth: 2,
                          backgroundColor: Colors.transparent,
                          pathBackgroundColor: Colors.black),
                    ),
                  )
                : controller.status
                    ? Stack(
                        children: [
                          GetBuilder<HomePageController>(
                            builder: (value) => GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: controller.kGooglePlex!,
                              markers: controller.markers,
                              compassEnabled: false,
                              polylines: controller.polylines,
                              onMapCreated: (onMapCreated) {
                                controller.mapController = onMapCreated;
                              },
                            ),
                          ),
                          if (!controller.isOnOrder)
                            Positioned(
                              top: 200.h,
                              child: Container(
                                height: 500.h,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.transparent,
                                child: StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("orders")
                                      .where('order_city',
                                          isEqualTo: controller.city)
                                      .where('is_succeed', isEqualTo: false)
                                      .where('is_canceled_by_customer',
                                          isEqualTo: false)
                                      .where('created_at',
                                          isEqualTo: DateFormat('yyyy-MM-dd HH')
                                              .format(DateTime.now()))
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Text('');
                                    } else {
                                      if (snapshot.data!.docs.isEmpty) {
                                        return const Text('');
                                      } else {
                                        return ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            final DocumentSnapshot
                                                documentSnapshot =
                                                snapshot.data!.docs[index];
                                            if (!documentSnapshot[
                                                        'drivers_declined']
                                                    .contains(controller
                                                        .userBase!
                                                        .driver_uid) &&
                                                !documentSnapshot[
                                                        'drivers_accepted']
                                                    .contains((controller
                                                        .userBase!
                                                        .driver_uid))) {
                                              double distance =
                                                  Geolocator.distanceBetween(
                                                      documentSnapshot[
                                                              "order_pickup_location"]
                                                          ['latitude'],
                                                      documentSnapshot[
                                                              "order_pickup_location"]
                                                          ['longitude'],
                                                      controller.latitude!,
                                                      controller.longtitude!);
                                              if ((distance / 1000) <
                                                      documentSnapshot[ 
                                                          'km_radius'] &&
                                                  controller.isWithOrder ==
                                                      false) { 
                                                return OrdersCard(
                                                  status: documentSnapshot[
                                                      "status"],
                                                  photo:
                                                      documentSnapshot["user"]
                                                          ["user_photo"],
                                                  username:
                                                      documentSnapshot["user"]
                                                          ["user_name"],
                                                  orderType: documentSnapshot[
                                                          "order_type"]
                                                      .toString(),
                                                  from: documentSnapshot[
                                                      "address_from"],
                                                  to: documentSnapshot[
                                                      "address_to"],
                                                  idOrder: documentSnapshot[
                                                      "order_id"],
                                                  drive: controller.userBase!,
                                                  distance: (distance / 1000)
                                                      .toStringAsFixed(2),
                                                  accepte: () async {
                                              String fcm=       documentSnapshot[
                                                              "customer_fcm"];
                                                      sendNotification([fcm],"confirmation order??","order accepted");
                                                    controller.isOnOrder = true;
                                                    controller.isWithOrder=true;
                                                    String fcm_driver=await SessionManager().get('driver_fcm');
                                                    FirebaseFirestore.instance.collection('orders').doc(  documentSnapshot[
                                                              "order_id"]).update(({
                                                                "driver_fcm":fcm_driver,

                                                              }));
                                                    FirebaseFirestore.instance
                                                        .collection('drivers')
                                                        .doc(controller
                                                            .userBase!
                                                            .driver_uid)
                                                        .update({
                                                      "is_on_order": true
                                                    });
                                                    controller.setRoad(
                                                        documentSnapshot[
                                                                "order_pickup_location"]
                                                            ["latitude"],
                                                        documentSnapshot[
                                                                "order_pickup_location"]
                                                            ["longitude"],
                                                        documentSnapshot[
                                                                "order_arrival_location"]
                                                            ["latitude"],
                                                        documentSnapshot[
                                                                "order_arrival_location"]
                                                            ["longitude"]);
                                                    addDriverToOrder(
                                                        controller.userBase!,
                                                        documentSnapshot[
                                                            "order_id"]);
                                                    controller.orderID =
                                                        documentSnapshot[
                                                            "order_id"];
                                                    controller.update();
                                                  },
                                                );
                                              } else {
                                                return const Text('');
                                              }
                                            } else {
                                              return const Text('');
                                            }
                                          },
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          if (controller.isOnOrder && !controller.startCourse)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Wrap(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("orders")
                                          .where("order_id",
                                              isEqualTo: controller.orderID)
                                          .snapshots(),
                                      builder: (ctx,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text('');
                                        } else {
                                          final DocumentSnapshot
                                              documentSnapshot =
                                              snapshot.data!.docs[0];

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              20.verticalSpace,
                                              Container(
                                                height: 5.h,
                                                width: 220.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          360),
                                                ),
                                              ),
                                              20.verticalSpace,
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 45.w,
                                                      height: 45.w,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                        child: Image.network(
                                                          documentSnapshot[
                                                                  'user']
                                                              ['user_photo'],
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    10.horizontalSpace,
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          documentSnapshot[
                                                                  'user']
                                                              ['user_name'],
                                                          style: bodyTextStyle,
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                          'order_type']
                                                                      .toString() !=
                                                                  "0"
                                                              ? "Voyage"
                                                              : "Course",
                                                          style: bodyTextStyle,
                                                        )
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      height: 45.h,
                                                      width: 45.h,
                                                      margin: EdgeInsets.only(
                                                          left: 6.w),
                                                      decoration: BoxDecoration(
                                                        color: primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          50,
                                                        ),
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          String customer_uid =
                                                              "";

                                                          var docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'orders')
                                                                  .doc(controller
                                                                      .orderID)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            customer_uid = data![
                                                                'customer_uid'];
                                                          }
                                                          String phoneNo = "";
                                                          docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      customer_uid)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            phoneNo = data![
                                                                'customer_phone_number'];
                                                          }

                                                          await FlutterPhoneDirectCaller
                                                              .callNumber(
                                                                  phoneNo);
                                                        },
                                                        icon: const Icon(
                                                          Boxicons
                                                              .bx_phone_call,
                                                          color: Colors.white,
                                                        ),
                                                        color: primary,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 45.h,
                                                      width: 45.h,
                                                      margin: EdgeInsets.only(
                                                          left: 6.w),
                                                      decoration: BoxDecoration(
                                                        color: primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          50,
                                                        ),
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          String customer_uid =
                                                              "";

                                                          var docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'orders')
                                                                  .doc(controller
                                                                      .orderID)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            customer_uid = data![
                                                                'customer_uid'];
                                                          }
                                                          String phoneNo = "";
                                                          docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      customer_uid)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            phoneNo = data![
                                                                'customer_phone_number'];
                                                          }

                                                          Share.share(
                                                              "Vous-etes ici??");
                                                        },
                                                        icon: const Icon(
                                                          Boxicons
                                                              .bx_message_rounded,
                                                          color: Colors.white,
                                                        ),
                                                        color: primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              20.verticalSpace,
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Boxicons.bx_dollar,
                                                          color: primary,
                                                        ),
                                                        10.horizontalSpace,
                                                        Text(
                                                          '${documentSnapshot['order_purchase_amount']} MAD',
                                                          style: bodyTextStyle,
                                                        ),
                                                      ],
                                                    ),
                                                    20.horizontalSpace,
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Boxicons.bxs_map,
                                                          color: primary,
                                                        ),
                                                        10.horizontalSpace,
                                                        Text(
                                                          '${documentSnapshot['nbre_km_depart_destination']} Km',
                                                          style: bodyTextStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              20.verticalSpace,
                                              documentSnapshot[
                                                      'is_canceled_by_customer']
                                                  ? InkWell(
                                                      onTap: () {
                                                        controller.startCourse =
                                                            false;
                                                        controller.isWithOrder =
                                                            false;
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'drivers')
                                                            .doc(controller
                                                                .userBase!
                                                                .driver_uid)
                                                            .update({
                                                          "is_on_order": false
                                                        });
                                                        controller.isOnOrder =
                                                            false;
                                                        controller.markers
                                                            .clear();
                                                        controller.polylines
                                                            .clear();
                                                        controller.update();
                                                        Get.offAll(() =>
                                                            const HomePage());
                                                      },
                                                      child: Container(
                                                        height: 55.h,
                                                        width: 260.w,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      360),
                                                        ),
                                                        child: Text(
                                                          'Client a annulé la commande',
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                "LatoSemiBold",
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        if (documentSnapshot[
                                                                'status'] ==
                                                            3) {
                                                          controller
                                                                  .startCourse =
                                                              false;
                                                          controller.isOnOrder =
                                                              false;
                                                          controller.isWithOrder =false;
                                                               FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'drivers')
                                                            .doc(controller
                                                                .userBase!
                                                                .driver_uid)
                                                            .update({
                                                          "is_on_order": false
                                                        });
                                                          controller.markers
                                                              .clear();
                                                          controller.polylines
                                                              .clear();
                                                          controller.update();
                                                          Get.offAll(() =>
                                                              const HomePage());
                                                        } else {
                                                          if (documentSnapshot[
                                                                  'driver_uid'] ==
                                                              controller
                                                                  .userBase!
                                                                  .driver_uid) {
                                                            controller
                                                                    .startCourse =
                                                                true;
                                                            controller.update();

                                                               String customer_fcm=       documentSnapshot[
                                                              "customer_fcm"];
                                                               String driver_fcm=       documentSnapshot[
                                                              "driver_fcm"];
                                                              

                                                              
                                                                sendNotification([customer_fcm,driver_fcm],"voyage","Voyage va commencer dans 30 min",whenDate:DateTime.tryParse( documentSnapshot[
                                                              "driver_pickup_time"]));
                                                     
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 55.h,
                                                        width: 320.w,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: documentSnapshot[
                                                                      'driver_uid'] ==
                                                                  controller
                                                                      .userBase!
                                                                      .driver_uid
                                                              ? primary
                                                              : Colors.grey
                                                                  .withOpacity(
                                                                      0.4),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      360),
                                                        ),
                                                        child: Text(
                                                          documentSnapshot[
                                                                      'driver_uid'] ==
                                                                  controller
                                                                      .userBase!
                                                                      .driver_uid
                                                              ? 'Continuer'
                                                              : 'En attente',
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                "LatoSemiBold",
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  controller.isOnOrder = false;
                                                  controller.isWithOrder=false;
                                                   FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'drivers')
                                                            .doc(controller
                                                                .userBase!
                                                                .driver_uid)
                                                            .update({
                                                          "is_on_order": false
                                                        });
                                                           String fcm=       documentSnapshot[
                                                              "customer_fcm"];
                                                     
                                                          sendNotification([fcm],"voyage annulé","Le chauffeur a annulé le voyage");
                                                  refuserOrder(
                                                      controller.userBase!,
                                                      controller.orderID);
                                                  controller.markers.clear();
                                                  controller.polylines.clear();
                                                  controller.getUserLocation();
                                                  controller.update();
                                                },
                                                child: Container(
                                                  height: 55.h,
                                                  width: 320.w,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            360),
                                                  ),
                                                  child: Text(
                                                    'Annuler',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white,
                                                      fontFamily:
                                                          "LatoSemiBold",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (controller.startCourse)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Wrap(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("orders")
                                          .where("order_id",
                                              isEqualTo: controller.orderID)
                                          .snapshots(),
                                      builder: (ctx,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text('');
                                        } else {
                                          final DocumentSnapshot
                                              documentSnapshot =
                                              snapshot.data!.docs[0];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              20.verticalSpace,
                                              Container(
                                                height: 5.h,
                                                width: 220.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          360),
                                                ),
                                              ),
                                              20.verticalSpace,
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 45.w,
                                                      height: 45.w,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.r),
                                                        child: Image.network(
                                                          documentSnapshot[
                                                                  'user']
                                                              ['user_photo'],
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                    ),
                                                    10.horizontalSpace,
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          documentSnapshot[
                                                                  'user']
                                                              ['user_name'],
                                                          style: bodyTextStyle,
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                                          'order_type']
                                                                      .toString() ==
                                                                  "0"
                                                              ? "Voyage"
                                                              : "Course",
                                                          style: bodyTextStyle,
                                                        )
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      height: 45.h,
                                                      width: 45.h,
                                                      margin: EdgeInsets.only(
                                                          left: 6.w),
                                                      decoration: BoxDecoration(
                                                        color: primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          50,
                                                        ),
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          String customer_uid =
                                                              "";

                                                          var docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'orders')
                                                                  .doc(controller
                                                                      .orderID)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            customer_uid = data![
                                                                'customer_uid'];
                                                          }
                                                          String phoneNo = "";
                                                          docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      customer_uid)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            phoneNo = data![
                                                                'customer_phone_number'];
                                                          }

                                                          await FlutterPhoneDirectCaller
                                                              .callNumber(
                                                                  phoneNo);
                                                        },
                                                        icon: const Icon(
                                                          Boxicons
                                                              .bx_phone_call,
                                                          color: Colors.white,
                                                        ),
                                                        color: primary,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 45.h,
                                                      width: 45.h,
                                                      margin: EdgeInsets.only(
                                                          left: 6.w),
                                                      decoration: BoxDecoration(
                                                        color: primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          50,
                                                        ),
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          String customer_uid =
                                                              "";

                                                          var docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'orders')
                                                                  .doc(controller
                                                                      .orderID)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            customer_uid = data![
                                                                'customer_uid'];
                                                          }
                                                          String phoneNo = "";
                                                          docSnapshot =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(
                                                                      customer_uid)
                                                                  .get();
                                                          if (docSnapshot
                                                              .exists) {
                                                            Map<String,
                                                                    dynamic>?
                                                                data =
                                                                docSnapshot
                                                                    .data();
                                                            phoneNo = data![
                                                                'customer_phone_number'];
                                                          }

                                                          Share.share(
                                                              "Vous-etes ici??");
                                                        },
                                                        icon: const Icon(
                                                          Boxicons
                                                              .bx_message_rounded,
                                                          color: Colors.white,
                                                        ),
                                                        color: primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              20.verticalSpace,
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Boxicons.bx_dollar,
                                                          color: primary,
                                                        ),
                                                        10.horizontalSpace,
                                                        Text(
                                                          '${documentSnapshot['order_purchase_amount']} MAD',
                                                          style: bodyTextStyle,
                                                        ),
                                                      ],
                                                    ),
                                                    20.horizontalSpace,
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Boxicons.bxs_map,
                                                          color: primary,
                                                        ),
                                                        10.horizontalSpace,
                                                        Text(
                                                          '${documentSnapshot['nbre_km_depart_destination']} Km',
                                                          style: bodyTextStyle,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              20.verticalSpace,
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                            () => HelpCenter(),
                                                            transition: Transition
                                                                .rightToLeft);
                                                      },
                                                      child: Container(
                                                        height: 55.h,
                                                        width: 55.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            360,
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Boxicons
                                                              .bx_help_circle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    documentSnapshot[
                                                            'is_canceled_by_customer']
                                                        ? InkWell(
                                                            onTap: () {
                                                              controller
                                                                      .startCourse =
                                                                  false;
                                                              controller
                                                                      .isOnOrder =
                                                                  false;
                                                                  controller.isWithOrder=false;
                                                                   FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'drivers')
                                                            .doc(controller
                                                                .userBase!
                                                                .driver_uid)
                                                            .update({
                                                          "is_on_order": false
                                                        });
                                                              controller.markers
                                                                  .clear();
                                                              controller
                                                                  .polylines
                                                                  .clear();
                                                              controller
                                                                  .update();
                                                              Get.offAll(() =>
                                                                  const HomePage());
                                                            },
                                                            child: Container(
                                                              height: 55.h,
                                                              width: 260.w,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: documentSnapshot[
                                                                        'is_start']
                                                                    ? primary
                                                                    : Colors
                                                                        .red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            360),
                                                              ),
                                                              child: Text(
                                                                'Client a annulé la commande',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      "LatoSemiBold",
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : InkWell(
                                                            onTap: () async {
                                                                 String fcm=       documentSnapshot[
                                                              "customer_fcm"];
                                                     
                                                                newOne()async {
                                                                  sendNotification([fcm],"voyage a commencée","Le chauffeur est en route");
                                                                  await updateStatusOrder(
                                                                      controller
                                                                          .orderID);
                                                                }


                                                               
                                                              documentSnapshot[
                                                                          'is_start'] ==
                                                                      false
                                                                  ? 
                                                                  newOne()
                                                                  : paiment(
                                                                      context,
                                                                      () async {
                                                                          sendNotification([fcm],"voyage est finis","au revoir");
                                                                      updateSuccedOrder(
                                                                          controller
                                                                              .orderID);
                                                                      controller
                                                                              .startCourse =
                                                                          false;
                                                                      controller
                                                                              .isOnOrder =
                                                                          false;
                                                                          controller.isWithOrder=false;
                                                                           FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'drivers')
                                                            .doc(controller
                                                                .userBase!
                                                                .driver_uid)
                                                            .update({
                                                          "is_on_order": false
                                                        });
                                                                      controller
                                                                          .markers
                                                                          .clear();
                                                                      controller
                                                                          .polylines
                                                                          .clear();
                                                                      await SessionManager().set(
                                                                          "order_id",
                                                                          controller
                                                                              .orderID);
                                                                      Get.offAll(
                                                                          () =>
                                                                              RateClient());
                                                                    });
                                                              controller
                                                                  .update();
                                                            },
                                                            child: Container(
                                                              height: 55.h,
                                                              width: 260.w,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: documentSnapshot[
                                                                            'is_start'] ==
                                                                        false
                                                                    ? primary
                                                                    : Colors
                                                                        .red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            360),
                                                              ),
                                                              child: Text(
                                                                documentSnapshot[
                                                                            'is_start'] ==
                                                                        false
                                                                    ? documentSnapshot['order_type'] !=
                                                                            0
                                                                        ? 'Commencez le voyage'
                                                                        : 'Commencer la course'
                                                                    : documentSnapshot['order_type'] !=
                                                                            0
                                                                        ? 'Finir le voyage'
                                                                        : 'Finir la course',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      15.sp,
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      "LatoSemiBold",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20.h,
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          240.verticalSpace,
                          Center(
                            child: Text(
                              'Vous êtes hors ligne',
                              style: primaryHeadlineTextStyle,
                            ),
                          ),
                          20.verticalSpace,
                          Text(
                            'Passez en ligne pour recevoir vos commandes',
                            style: bodyTextStyle,
                          ),
                          40.verticalSpace,
                          OutlineButton(
                            text: 'Passer en ligne',
                            function: () {
                              controller.status = true;
                              controller.goOnline();
                              controller.update();
                            },
                          ),
                          const Spacer(),
                          SupportButton(mode: dark),
                          80.verticalSpace,
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
