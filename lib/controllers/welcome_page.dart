import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motopickupdriver/utils/models/tmpUser.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/queries.dart';
import 'package:motopickupdriver/utils/services.dart';
import 'package:motopickupdriver/views/completeYourProfile/complete_profile.dart';
import 'package:motopickupdriver/views/congrats_page.dart';
import 'package:motopickupdriver/views/home_page.dart';

import '../utils/alert_dialog.dart';

class WelcomeController extends GetxController {
  RxBool loading = false.obs;




  Future<String> isUserExist(email) async {
  bool exist = false;
  String provider = '';
  await FirebaseFirestore.instance
      .collection('users')
      .where('customer_email', isEqualTo: email)
      .where('is_deleted_account', isEqualTo: false)
      .snapshots()
      .first
      .then((value) async { 
        if (value.size != 0) provider = value.docs.first.get('customer_auth_type');
      });

  await FirebaseFirestore.instance
      .collection('drivers')
      .where('driver_email', isEqualTo: email)
      .where('is_deleted_account', isEqualTo: false)
      .snapshots()
      .first
      .then((value) async {
         
        if (value.size != 0) provider = value.docs.first.get('driver_type_auth');
      });

  return provider;
}


  void googleAuth(context) async {
    loading.toggle();
    GoogleSignInAccount? googleAccount =
        await GoogleSignIn(scopes: ['profile', 'email']).signIn(); 
        if(googleAccount!=null){
            await isUserExist(googleAccount!.email.toLowerCase()).then((value) async {
      if (value != "Google" && value != "") {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn(scopes: ['profile', 'email']).signOut();
        return showAlertDialogOneButton(
            context,
            "L'utilisateur existe déjà",
            "Il existe déjà un compte avec cet e-mail, veuillez essayer de vous connecter avec $value",
          "Ok");
}
else{
   GoogleSignInAuthentication googleSignInAuthentication =
        await googleAccount!.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);
    UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? user = authResult.user;
    await userExist(user!.uid).then((value) async {
      await SessionManager().set(
        'tmpUser',
        TmpUser(
          email: user.email!,
          phoneNo: '',
          password: '',
          type_account: 'google',
        ),
      );
      if (value) {
        await getUser(user.uid).then((value) async {
          value.driver_last_login_date =
              DateFormat('dd-MM-yyyy HH:mm', 'Fr_fr').format(DateTime.now());
          UserBase userBase = value;
          await completeUser(userBase);
          await GetStorage().write('isLoggedIn', true);
          await SessionManager().set('currentUser', userBase);
          updateFcm();
          await getUserStatus(user.uid).then((value) async {
            if (value == 0) {
              Get.offAll(() => CompleteProfile(),
                  transition: Transition.rightToLeft);
            }
            if (value == 1) {
              Get.offAll(() => Congrats(), transition: Transition.rightToLeft);
            } else {
              Get.offAll(() => const HomePage(),
                  transition: Transition.rightToLeft);
            }
          });
        });
      } else {
        UserBase userBase = UserBase(
          driver_uid: user.uid,
          driver_full_name: user.displayName!,
          driver_email: user.email!,
          driver_sexe: '',
          driver_type_auth: 'Google',
          driver_date_naissance: '',
          driver_phone_number: '',
          driver_profile_picture: user.photoURL!,
          driver_registration_date:
              DateFormat('dd-MM-yyyy Hh:mm', 'Fr_fr').format(DateTime.now()),
          driver_last_login_date:
              DateFormat('dd-MM-yyyy Hh:mm', 'Fr_fr').format(DateTime.now()),
          driver_current_city: '',
          driver_latitude: 0,
          driver_longitude: 0,
          is_deleted_account: false,
          is_activated_account: false,
          is_verified_account: false,
          is_blacklisted_account: false,
          is_online: false,
          is_on_order: false,
          is_driver: 0,
          is_password_change: false,
          driver_cancelled_delivery: 0,
          driver_succeded_delivery: 0,
          driver_planned_delivery: 0,
          driver_cancelled_trip: 0,
          driver_succeded_trip: 0,
          driver_planned_trip: 0,
          driver_stars_mean: 0,
          driver_note: 0,
          driver_motocylces: [],
          driver_identity_card_number: "",
          driver_identity_card_picture: "",
          driver_identity_card_expiration_date: "",
          driver_driving_licence_number: "",
          driver_driving_licence_picture: "",
          driver_driving_licence_expiration_date: "",
          driver_order_total_amount: "",
          driver_anthropometrique: "",
          driver_total_orders: 0, 
          driver_total_paid: 0,
        );
        GetStorage().write('isLoggedIn', true);
        await SessionManager().set('currentUser', userBase);
        await createUser(userBase).then(
          (value) async {
              updateFcm();
            Get.offAll(() => CompleteProfile(),
                transition: Transition.rightToLeft);
          },
        );
      }
    });
}
});
  loading.toggle();
        }
        else{
          loading.toggle();
        } 
  }

  void facebookAuth() async {
    loading.toggle();
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(facebookCredential);
    User? user = authResult.user;
    loading.toggle();
  }

  




}
