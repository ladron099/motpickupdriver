// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/complete_profile.dart';
import 'package:motopickupdriver/views/onboarding/onboarding_page.dart';

import '../views/congrats_page.dart';
import '../views/home_page.dart';

GetStorage box = GetStorage();

Future<Widget?> initWidget() async {
  bool isVerified = false, isActivated = false;
  Widget? mainPage;
   bool isLoggedIn = box.read('isLoggedIn') ?? false; 
  if (isLoggedIn) { 
    await getCurrentUser().then((value) async {
      isActivated = value!.is_activated_account;
      isVerified = value.is_verified_account;
          print(value!.is_activated_account);
          print(value!.is_verified_account);
    });
    
  
    isVerified
        ? (isActivated ? mainPage = const HomePage() : mainPage = Congrats())
        : mainPage = CompleteProfile();
  } else {
    mainPage = const OnBoardingPage();
  }  

  return mainPage;
}

goTo(Widget target) {
  Get.to(() => target, transition: Transition.rightToLeft);
}

goToOff(Widget target) {
  Get.offAll(() => target, transition: Transition.rightToLeft);
}

goBackOff(Widget target) {
  Get.offAll(() => target, transition: Transition.leftToRight);
}
