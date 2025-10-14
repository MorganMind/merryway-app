import 'package:flutter/material.dart';
import 'package:merryway/config/environment.dart';
import 'package:merryway/main.dart';

void main() {
  Environment.initialize(BuildFlavor.development);
  mainCommon();
} 