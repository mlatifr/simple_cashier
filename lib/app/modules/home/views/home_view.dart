import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_cashier/app/modules/cart/controllers/cart_controller.dart';
import 'package:simple_cashier/app/modules/home/model/product_model.dart';
import 'package:simple_cashier/app/modules/login/controllers/login_controller.dart';
import 'package:simple_cashier/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Cashier'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.CART);
        },
        child: const Icon(Icons.trolley),
      ),
      endDrawer: _drawerWidget(),
      body: _gridItemWidget(),
    );
  }

  Widget _gridItemWidget() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return Card(
            elevation: 2,
            child: InkWell(
              onTap: () {
                _showAddToCartDialog(context, product);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                      child: const Icon(
                        Icons.inventory,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${product.price}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Stock: ${product.stock}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Code: ${product.code}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showAddToCartDialog(BuildContext context, Product product) {
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambahkan ke Keranjang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Harga: Rp ${product.price}'),
            Text('Stok: ${product.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () async {
              final int quantity = int.tryParse(quantityController.text) ?? 1;
              if (quantity > 0 &&
                  quantity <= product.stock &&
                  product.id != null) {
                // Add to cart
                int result = await Get.put(CartController()).addToCart(product.id!, quantity);
                Navigator.pop(context);
                
                if (result >= 0) {
                  Get.snackbar(
                    'Sukses',
                    '${product.name} ditambahkan ke keranjang',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  // Refresh products to show updated stock
                  Get.find<HomeController>().loadProducts();
                } else if (result == -1) {
                  Get.snackbar(
                    'Gagal',
                    'Produk tidak ditemukan',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  );
                } else if (result == -2) {
                  Get.snackbar(
                    'Gagal',
                    'Stok tidak mencukupi',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  );
                } else {
                  Get.snackbar(
                    'Gagal',
                    'Terjadi kesalahan saat menambahkan ke keranjang',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                  );
                }
              } else {
                Get.snackbar(
                  'Gagal',
                  'Jumlah tidak valid atau melebihi stok',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                );
              }
            },
            child: const Text('TAMBAH'),
          ),
        ],
      ),
    );
  }

  Drawer _drawerWidget() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Add logout logic here
              LoginController().logout();
            },
          ),
        ],
      ),
    );
  }
}
