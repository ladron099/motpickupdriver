// ignore_for_file: must_be_immutable

import 'package:boxicons/boxicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:motopickupdriver/controllers/auth/verify_number.dart';
import 'package:motopickupdriver/utils/buttons.dart';
import 'package:motopickupdriver/utils/colors.dart';
import 'package:motopickupdriver/utils/typography.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerfiyNumber extends StatelessWidget {
  VerfiyNumber({Key? key}) : super(key: key);
  var controller = Get.put(VerfiyNumberController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetBuilder<VerfiyNumberController>(
        init: VerfiyNumberController(),
        builder: (value) => LoadingOverlay(
          isLoading: controller.loading.value,
          color: dark,
          progressIndicator: const CircularProgressIndicator(
            color: dark,
            strokeWidth: 6.0,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          child: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                onTap: () => Get.back(),
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
            body: controller.isTrue.value
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        20.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'Vérifiez votre numéro de téléphone',
                            style: primaryHeadlineTextStyle,
                          ),
                        ),
                        40.verticalSpace,
                        GetBuilder<VerfiyNumberController>(
                          init: VerfiyNumberController(),
                          builder: (value) => Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'Un SMS a été envoyé au ${controller.tmpUser!.phoneNo}, entrez le code reçu pour valider votre inscription.',
                              style: bodyTextStyle,
                            ),
                          ),
                        ),
                        40.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: PinCodeTextField(
                            length: 6,
                            obscureText: false,
                            animationType: AnimationType.fade,
                            controller: controller.code,
                            keyboardType: TextInputType.phone,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50.w,
                              fieldWidth: 50.w,
                              activeFillColor: Colors.transparent,
                              inactiveFillColor: Colors.transparent,
                              selectedColor: primary,
                              selectedFillColor: Colors.transparent,
                              inactiveColor: border,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            textStyle: TextStyle(
                              fontSize: 18.sp,
                              color: dark,
                              height: 1.4,
                              fontFamily: "LatoSemiBold",
                            ),
                            onCompleted: (v) {
                              controller.submit(context);
                            },
                            beforeTextPaste: (text) {
                              return true;
                            },
                            onChanged: (String value) {},
                            appContext: context,
                          ),
                        ),
                        25.verticalSpace,
                        PrimaryButton(
                          text: "Continuer",
                          function: () {
                            controller.submit(context);
                          },
                        ),
                        220.verticalSpace,
                        InkWell(
                          onTap: () {
                            if (controller.second == 0) {
                              controller.reSendCode();
                            }
                          },
                          child: Center(
                            child: GetBuilder<VerfiyNumberController>(
                              init: VerfiyNumberController(),
                              builder: (value) => Text(
                                "Je n'ai pas reçu le code, cliquez ici dans ${controller.second} secondes",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: controller.second == 0
                                      ? dark
                                      : dark.withOpacity(0.4),
                                  fontFamily: "LatoRegular",
                                ),
                              ),
                            ),
                          ),
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
