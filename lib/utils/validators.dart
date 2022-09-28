import 'package:flutter/material.dart';
import 'package:weappear_localizations/weappear_localizations.dart';

/// Provides mail validation
String? validateEmail(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.l10n.youHaveToCompleteThisField;
  }

  final _value = value.trim();

  final emailRegExp = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  if (!emailRegExp.hasMatch(_value)) {
    return context.l10n.invalidMail;
  }
  return null;
}
