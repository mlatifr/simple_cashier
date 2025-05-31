import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/database_helper.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  final Rx<TextEditingController> usernameController =
      TextEditingController().obs;
  final Rx<TextEditingController> passwordController =
      TextEditingController().obs;
  final RxBool isPasswordHidden = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden(!isPasswordHidden.value);
    update();
  }

  Future<void> register() async {
    if (usernameController.value.text.isEmpty ||
        passwordController.value.text.isEmpty) {
      errorMessage('Username dan password tidak boleh kosong');
      return;
    }

    isLoading(true);
    errorMessage('');

    try {
      // Cek apakah username sudah ada
      final existingUser =
          await _databaseHelper.getUser(usernameController.value.text);

      if (existingUser != null) {
        errorMessage('Username sudah digunakan');
        isLoading(false);
        return;
      }

      // Simpan user baru
      final user = {
        'username': usernameController.value.text,
        'password': passwordController.value.text,
        'isLogin': '0',
      };

      await _databaseHelper.insertUser(user);

      // Kembali ke halaman login
      Get.offNamed(Routes.LOGIN);
      Get.snackbar(
        'Sukses',
        'Registrasi berhasil, silahkan login',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
