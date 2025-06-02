import 'package:get/get.dart';
import 'package:simple_cashier/app/data/database_helper.dart';
import 'package:simple_cashier/app/modules/home/model/product_model.dart';

class HomeController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final RxList<Product> products = <Product>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('items');
      products.value = List.generate(maps.length, (i) {
        return Product.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error loading products: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
