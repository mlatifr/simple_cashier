import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/database_helper.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    checkLoginStatus();
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

  Future<void> logout() async {
    try {
      // Update all users' login status to inactive (0)
      await _databaseHelper.logout();

      // Navigate back to login page
      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage('Error during logout: ${e.toString()}');
    }
  }

  Future<void> login() async {
    if (usernameController.value.text.isEmpty ||
        passwordController.value.text.isEmpty) {
      errorMessage('Username dan password tidak boleh kosong');

      return;
    }

    isLoading(true);
    errorMessage('');

    try {
      // Cek apakah username ada
      final user = await _databaseHelper.getUser(usernameController.value.text);

      if (user == null) {
        errorMessage('Username tidak ditemukan');
        isLoading(false);

        await Future.delayed(const Duration(seconds: 2));
        errorMessage('');
        return;
      }

      // Cek password
      if (user['password'] != passwordController.value.text) {
        errorMessage('Password salah');
        isLoading(false);
        await Future.delayed(const Duration(seconds: 2));
        errorMessage('');
        return;
      }
      // Update user login status to active
      await _databaseHelper.updateLoginStatus(usernameController.value.text, 1);

      // Login berhasil, navigasi ke home
      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Sukses',
        'Login berhasil',
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

  Future<void> checkLoginStatus() async {
    try {
      // Check if user exists in database
      final user = await _databaseHelper.readIsLogin();

      if (user != null) {
        // User is logged in, navigate to home
        await Get.offAllNamed(Routes.HOME);
        // Remove snackbar to prevent UI clutter on app startup
      } else {
        // User not logged in, stay on login page
        // Remove error message to keep UI clean on initial load
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      print('Error checking login status: ${e.toString()}');
      // Silent error handling for startup flow
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
