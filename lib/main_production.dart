import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:merryway/config/environment.dart';
import 'package:merryway/main.dart';

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
  Environment.initialize(BuildFlavor.production);
  mainCommon();
} 