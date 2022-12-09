// ignore_for_file: must_be_immutable

import 'package:boxicons/boxicons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:motopickupdriver/components/inputs.dart';
import 'package:motopickupdriver/controllers/profile/edit_info.dart';
import 'package:motopickupdriver/utils/buttons.dart';
import 'package:motopickupdriver/utils/colors.dart';
import 'package:motopickupdriver/utils/navigations.dart';
import 'package:motopickupdriver/utils/typography.dart';
import 'package:motopickupdriver/views/profile/profile_page.dart';

class EditInfo extends StatelessWidget {
  EditInfo({Key? key}) : super(key: key);
  var controller = Get.put(EditInfoController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => goBackOff(ProfilePage()),
      child: SafeArea(
        child: GetBuilder<EditInfoController>(
          init: EditInfoController(),
          builder: (value) => Scaffold(
            backgroundColor: scaffold,
            appBar: !controller.isTrue.value
                ? AppBar(
                    leading: Icon(
                      Boxicons.bx_arrow_back,
                      color: Colors.transparent,
                      size: 35.h,
                    ),
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
                      onTap: () => goBackOff(ProfilePage()),
                      child: Icon(
                        Boxicons.bx_arrow_back,
                        color: primary,
                        size: 30.h,
                      ),
                    ),
                    toolbarHeight: 80.h,
                    title: Image.asset(
                      'assets/images/logoMoto_colored.png',
                      height: 50.h,
                    ),
                    centerTitle: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
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
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        20.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'Modifier les données personnelles',
                            style: primaryHeadlineTextStyle,
                          ),
                        ),
                        25.verticalSpace,
                        InputTextField(
                          hintText: 'Entrez votre nom complet',
                          type: TextInputType.text,
                          controller: controller.fullname,
                          icon: Boxicons.bxs_user,
                        ),
                        5.verticalSpace,
                        InputTextField(
                          enable:false,
                          hintText: 'Entrez votre Email',
                          type: TextInputType.emailAddress,
                          controller: controller.email,
                          icon: Boxicons.bxs_envelope,
                        ),
                        5.verticalSpace,
                        
                        GetBuilder<EditInfoController>(
                          init: EditInfoController(),
                          builder: (value) => InputDatePicker(
                            dateText: controller.birthday,
                            icon: Boxicons.bxs_calendar,
                            // ignore: avoid_returning_null_for_void
                            function: () =>null,
                          ),
                        ),
                        17.verticalSpace,
                        GetBuilder<EditInfoController>(
                          init: EditInfoController(),
                          builder: (value) => DropDownMenu(
                            items: controller.dropdownSexeItems,
                            listItem: controller.sexe,
                            function: (value) {
                              controller.dropDownMenuChange(value);
                              controller.update();
                            },
                          ),
                        ),
                        20.verticalSpace,
                        InputTextField(
                          hintText:
                              'Numéro de carte d\'identification national',
                          type: TextInputType.text,
                          controller: controller.cni,
                          icon: Boxicons.bxs_key,
                          enable: false,
                        ),
                        20.verticalSpace,
                        PrimaryButton(
                          text: 'Mettre à jour',
                          function: () async {
                            controller.submit(context);
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
