import 'package:flutter/material.dart';

const double _horizontalPaddingSmall = 8;
const double _horizontalPaddingMedium = 16;
const double _horizontalPaddingLarge = 24;

const Widget horizontalSpaceTiny = SizedBox(width: 4);
const Widget horizontalSpaceSmall = SizedBox(width: 8);
const Widget horizontalSpaceMedium = SizedBox(width: 16);
const Widget horizontalSpaceLarge = SizedBox(width: 24);

const Widget verticalSpaceTiny = SizedBox(height: 4);
const Widget verticalSpaceSmall = SizedBox(height: 8);
const Widget verticalSpaceMedium = SizedBox(height: 16);
const Widget verticalSpaceLarge = SizedBox(height: 24);
const Widget verticalSpaceExtraLarge = SizedBox(height: 48);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

EdgeInsets screenPaddingSmall =
    const EdgeInsets.symmetric(horizontal: _horizontalPaddingSmall);
EdgeInsets screenPaddingMedium =
    const EdgeInsets.symmetric(horizontal: _horizontalPaddingMedium);
EdgeInsets screenPaddingLarge =
    const EdgeInsets.symmetric(horizontal: _horizontalPaddingLarge);
