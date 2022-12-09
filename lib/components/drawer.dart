// ignore_for_file: file_names, must_be_immutable

import 'package:boxicons/boxicons.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:motopickupdriver/utils/colors.dart';
import 'package:motopickupdriver/utils/functions.dart';
import 'package:motopickupdriver/utils/models/userBase.dart';
import 'package:motopickupdriver/utils/typography.dart';
import 'package:motopickupdriver/views/help_center.dart';
import 'package:motopickupdriver/views/my_command.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';
import 'package:motopickupdriver/views/settings_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../utils/services.dart';

class NavigationDrawerWidget extends StatefulWidget {
  UserBase? currentUser;
  NavigationDrawerWidget({required this.currentUser, Key? key})
      : super(key: key);

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = const EdgeInsets.symmetric(horizontal: 20);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight:
                Radius.circular(context.locale.toString() == 'fr' ? 50 : 0),
            bottomRight:
                Radius.circular(context.locale.toString() == 'fr' ? 50 : 0),
            topLeft:
                Radius.circular(context.locale.toString() == 'ar' ? 50 : 0),
            bottomLeft:
                Radius.circular(context.locale.toString() == 'ar' ? 50 : 0),
          ),
        ),
        color: primary,
        child: Column(
          children: [
            buildHeader(
              urlImage: widget.currentUser!.driver_profile_picture,
              name: widget.currentUser!.driver_full_name,
              stars: widget.currentUser!.driver_stars_mean.round(),
              onClicked: () {},
            ),
            Divider(
              color: light,
              thickness: 3.h,
            ),
            Expanded(
              child: ListView(
                children: [
                  buildMenuItem(
                    text: 'Accueil',
                    icon: Boxicons.bx_home_alt,
                    onClicked: () {
                      Navigator.pop(context);
                    },
                  ),
                  buildMenuItem(
                    text: 'Informations du profil',
                    icon: Boxicons.bx_user,
                    onClicked: () {
                      Navigator.pop(context);
                      Get.offAll(() => ProfilePage(),
                          transition: Transition.rightToLeft);
                    },
                  ),
                  buildMenuItem(
                    text: 'Mes commandes',
                    icon: Boxicons.bx_package,
                    onClicked: () {
                      Navigator.pop(context);
                      Get.to(() => MyCommand(),
                          transition: Transition.rightToLeft);
                    },
                  ),
                  buildMenuItem(
                    text: 'Paramètres',
                    icon: FontAwesomeIcons.gear,
                    onClicked: () {
                      Navigator.pop(context);
                      Get.to(() => SettingScreen(),
                          transition: Transition.rightToLeft);
                    },
                  ),
                  buildMenuItem(
                    text: "Centre d'aide et support",
                    icon: Boxicons.bx_help_circle,
                    onClicked: () {
                      Navigator.pop(context);
                      Get.to(() => HelpCenter(),
                          transition: Transition.rightToLeft);
                    },
                  ),
                  buildMenuItem(
                    text: 'Politique de confidentialité',
                    icon: Boxicons.bx_file_blank,
                    onClicked: () {
                      Navigator.pop(context);
                      launchUrlString(
                        'https://motopickup.com/termes-de-references.html',
                      );
                    },
                  ),
                  buildMenuItem(
                    text: "Conditions d'utilisation",
                    icon: Boxicons.bx_archive,
                    onClicked: () {
                      Navigator.pop(context);
                      launchUrlString(
                        'https://motopickup.com/conditions-generales.html',
                      );
                    },
                  ),
                ],
              ),
            ),
            buildMenuItem(
              text: 'Se déconnecter',
              icon: Boxicons.bx_log_out,
              onClicked: ()async {
                Navigator.pop(context);
                logout(context);
                // String fcm= await SessionManager().get('driver_fcm');
                // print(fcm+"wl");
                //  await sendPlanifiedNotification([fcm],"this is 12:04","this is 12:00",DateTime(2022,12,08,12,04));
              // await OneSignal.shared.postNotification(OSCreateNotification(content: "commande hh",playerIds: [fcm]) ) ; 

              }
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String name,
    required int stars,
    required VoidCallback onClicked,
  }) =>
      InkWell(
        onTap: onClicked,
        child: Container(
          padding: padding.add(
            EdgeInsets.symmetric(vertical: 12.w),
          ),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              SizedBox(
                height: 90.h,
                width: 90.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(360),
                  child: Image.network(
                    urlImage,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(name.toUpperCase(), style: drawerTextStyle),
                  20.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        stars >= 1 ? Boxicons.bxs_star : Boxicons.bx_star,
                        color: light,
                      ),
                      Icon(
                        stars >= 2 ? Boxicons.bxs_star : Boxicons.bx_star,
                        color: light,
                      ),
                      Icon(
                        stars >= 3 ? Boxicons.bxs_star : Boxicons.bx_star,
                        color: light,
                      ),
                      Icon(
                        stars >= 4 ? Boxicons.bxs_star : Boxicons.bx_star,
                        color: light,
                      ),
                      Icon(
                        stars >= 5 ? Boxicons.bxs_star : Boxicons.bx_star,
                        color: light,
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      );

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;

    return InkWell(
      onTap: onClicked,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text, style: drawerTextStyle).tr(),
        hoverColor: hoverColor,
      ),
    );
  }
}
