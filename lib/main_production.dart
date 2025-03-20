import 'package:flutter/material.dart';
import 'package:app/config/environment.dart';
import 'package:app/main.dart';

void main() {
  Environment.initialize(BuildFlavor.production);
  mainCommon();
} 