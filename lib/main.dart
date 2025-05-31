import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_cashier/app/modules/login/controllers/login_controller.dart';
import 'app/data/database_helper.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database
  await DatabaseHelper().database;
  await LoginController().checkLoginStatus();

  runApp(
    GetMaterialApp(
      title: "Simple Cashier",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    ),
  );
}
