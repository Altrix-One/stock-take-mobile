import 'package:flutter/material.dart';

// const Color primaryColor = Colors.indigo;
const Color primaryColor = Color.fromRGBO(26, 35, 52, 1);
// const Color secondaryColor = Colors.indigoAccent;
const Color secondaryColor = Color.fromRGBO(43, 57, 85, 1);
const Color screenBgColor = Color(0xFFF4F4F4);
const Color whiteColor = Colors.white;
const Color blackColor = Colors.black;
const Color black3CColor = Color(0xFF3C3C3C);
const Color black33Color = Color(0xFF333333);
const Color greyColor = Color(0xFF949494);
const Color greyD4Color = Color(0xFFD4D4D4);
const Color greyB4Color = Color(0xFFB4B4B4);
const Color f8Color = Color(0xFFFBF8F8);
const Color greenColor = Color(0xFF189915);
const Color redColor = Color(0xFFD24036);
const Color d9E3EAColor = Color(0xFFD9E3EA);
const Color darkBlueColor = Colors.indigoAccent;
// const Color darkBlueColor = Color(0xFF1E4799);
const Color darkGreenColor = Color(0xFF1E996D);
const Color darkRedColor = Color(0xFFD2182D);
const Color gradientStartColor = Color.fromRGBO(51, 69, 102, 1);
// const Color gradientStartColor = Color(0xFF1f4590);
const Color greyBorderColor = Color(0xFFcfd6e4);
const Color gradientEndColor = Color.fromRGBO(60, 80, 119, 1);
// const Color gradientEndColor = Color(0xFF234591);

const double fixPadding = 7.0;

const SizedBox heightSpace = SizedBox(height: fixPadding);
const SizedBox height5Space = SizedBox(height: 5.0);
const SizedBox height200Space = SizedBox(height: 200.0);
const SizedBox widthSpace = SizedBox(width: fixPadding);
const SizedBox width5Space = SizedBox(width: 5.0);

SizedBox heightBox(double height) => SizedBox(height: height);

SizedBox widthBox(double width) => SizedBox(width: width);

const TextStyle semibold15White = TextStyle(
    color: whiteColor,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    fontFamily: 'Montserrat');

const TextStyle bold18White =
    TextStyle(color: whiteColor, fontSize: 18.0, fontWeight: FontWeight.w700);

const TextStyle bold18Primary =
    TextStyle(color: primaryColor, fontSize: 18.0, fontWeight: FontWeight.w700);

const TextStyle bold17Primary =
    TextStyle(color: primaryColor, fontSize: 17.0, fontWeight: FontWeight.w700);

const TextStyle semibold28White =
    TextStyle(color: whiteColor, fontSize: 28.0, fontWeight: FontWeight.w600);

const TextStyle semibold20White =
    TextStyle(color: whiteColor, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold18White =
    TextStyle(color: whiteColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16White =
    TextStyle(color: whiteColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold20Black33 =
    TextStyle(color: black33Color, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold28Black33 =
    TextStyle(color: black33Color, fontSize: 28.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Black33 =
    TextStyle(color: black33Color, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold17Black33 =
    TextStyle(color: black33Color, fontSize: 17.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Black33 =
    TextStyle(color: black33Color, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Black33 =
    TextStyle(color: black33Color, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Black33 =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Grey =
    TextStyle(color: greyColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Grey =
    TextStyle(color: greyColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Grey =
    TextStyle(color: greyColor, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Grey =
    TextStyle(color: greyColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold13Grey =
    TextStyle(color: greyColor, fontSize: 13.0, fontWeight: FontWeight.w600);

const TextStyle semibold20Primary =
    TextStyle(color: primaryColor, fontSize: 20.0, fontWeight: FontWeight.w600);

const TextStyle semibold18Primary =
    TextStyle(color: primaryColor, fontSize: 18.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Primary =
    TextStyle(color: primaryColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold15Primary =
    TextStyle(color: primaryColor, fontSize: 15.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Primary =
    TextStyle(color: primaryColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle semibold24Secondary = TextStyle(
    color: secondaryColor, fontSize: 24.0, fontWeight: FontWeight.w600);

const TextStyle semibold17Secondary = TextStyle(
    color: secondaryColor, fontSize: 17.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Secondary = TextStyle(
    color: secondaryColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Red =
    TextStyle(color: redColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold16Green =
    TextStyle(color: greenColor, fontSize: 16.0, fontWeight: FontWeight.w600);

const TextStyle semibold14Green =
    TextStyle(color: greenColor, fontSize: 14.0, fontWeight: FontWeight.w600);

const TextStyle medium16Black33 =
    TextStyle(color: black33Color, fontSize: 16.0, fontWeight: FontWeight.w500);

const TextStyle medium15Black33 =
    TextStyle(color: black33Color, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14Black33 =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12Black33 =
    TextStyle(color: black33Color, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium14Black3C =
    TextStyle(color: black33Color, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium15White =
    TextStyle(color: whiteColor, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14White =
    TextStyle(color: whiteColor, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12White =
    TextStyle(color: whiteColor, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium20Grey =
    TextStyle(color: greyColor, fontSize: 20.0, fontWeight: FontWeight.w500);

const TextStyle medium18Grey =
    TextStyle(color: greyColor, fontSize: 18.0, fontWeight: FontWeight.w500);

const TextStyle medium16Grey =
    TextStyle(color: greyColor, fontSize: 16.0, fontWeight: FontWeight.w500);

const TextStyle medium15Grey =
    TextStyle(color: greyColor, fontSize: 15.0, fontWeight: FontWeight.w500);

const TextStyle medium14Grey =
    TextStyle(color: greyColor, fontSize: 14.0, fontWeight: FontWeight.w500);

const TextStyle medium12Grey =
    TextStyle(color: greyColor, fontSize: 12.0, fontWeight: FontWeight.w500);

const TextStyle medium20Primary =
    TextStyle(color: primaryColor, fontSize: 20.0, fontWeight: FontWeight.w500);

const TextStyle medium30Primary =
    TextStyle(color: primaryColor, fontSize: 30.0, fontWeight: FontWeight.w500);
