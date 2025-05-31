import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/data/database_helper.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database
  await DatabaseHelper().database;

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
