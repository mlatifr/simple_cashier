import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_cashier/app/data/database_helper.dart';
import 'package:simple_cashier/app/modules/cart/models/cart_item_model.dart';
import 'package:simple_cashier/app/modules/home/controllers/home_controller.dart';

class CartController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadCartItems() async {
    isLoading.value = true;
    try {
      final List<Map<String, dynamic>> cartData = await _databaseHelper.getCartItems();
      cartItems.value = cartData.map((item) => CartItem.fromMap(item)).toList();
      _calculateTotal();
    } catch (e) {
      print('Error loading cart items: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<int> addToCart(int itemId, int quantity) async {
    try {
      int result = await _databaseHelper.addToCart(itemId, quantity);
      await loadCartItems();
      
      // Refresh product list in HomeController to reflect stock changes
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadProducts();
      }
      
      return result;
    } catch (e) {
      print('Error adding to cart: $e');
      return -3; // Error occurred
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    try {
      if (item.id != null && item.itemId != null) {
        // Get current item data to check stock
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> itemData = await db.query(
          'items',
          where: 'id = ?',
          whereArgs: [item.itemId],
        );
        
        if (itemData.isNotEmpty) {
          int currentStock = itemData.first['stock'];
          
          // Check if there's enough stock
          if (currentStock > 0) {
            // Decrease stock by 1
            await _databaseHelper.updateStock(item.itemId!, currentStock - 1);
            
            // Increase cart quantity
            await _databaseHelper.updateCartItemQuantity(item.id!, item.quantity + 1);
            await loadCartItems();
            
            // Refresh product list in HomeController to reflect stock changes
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().loadProducts();
            }
          } else {
            // Show error message if no stock available
            Get.snackbar(
              'Gagal',
              'Stok tidak mencukupi',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.1),
            );
          }
        }
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(CartItem item) async {
    try {
      if (item.id != null && item.itemId != null) {
        // Get current item data to update stock
        final db = await _databaseHelper.database;
        final List<Map<String, dynamic>> itemData = await db.query(
          'items',
          where: 'id = ?',
          whereArgs: [item.itemId],
        );
        
        if (itemData.isNotEmpty) {
          int currentStock = itemData.first['stock'];
          // Increase stock by 1 when decreasing cart quantity
          await _databaseHelper.updateStock(item.itemId!, currentStock + 1);
          
          if (item.quantity > 1) {
            await _databaseHelper.updateCartItemQuantity(item.id!, item.quantity - 1);
          } else {
            await _databaseHelper.removeFromCart(item.id!);
          }
          
          await loadCartItems();
          
          // Refresh product list in HomeController to reflect stock changes
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().loadProducts();
          }
        }
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  Future<void> removeItem(int cartId) async {
    try {
      // Get cart item details before removing
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> cartItemData = await db.query(
        'cart',
        where: 'id = ?',
        whereArgs: [cartId],
      );
      
      if (cartItemData.isNotEmpty) {
        int itemId = cartItemData.first['item_id'];
        int quantity = cartItemData.first['quantity'];
        
        // Get current item stock
        final List<Map<String, dynamic>> itemData = await db.query(
          'items',
          where: 'id = ?',
          whereArgs: [itemId],
        );
        
        if (itemData.isNotEmpty) {
          int currentStock = itemData.first['stock'];
          // Return quantity to stock
          await _databaseHelper.updateStock(itemId, currentStock + quantity);
        }
      }
      
      await _databaseHelper.removeFromCart(cartId);
      await loadCartItems();
      
      // Refresh product list in HomeController to reflect stock changes
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadProducts();
      }
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      // Get all cart items before clearing
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> cartItems = await db.rawQuery('''
        SELECT cart.id, cart.item_id, cart.quantity, items.stock
        FROM cart
        INNER JOIN items ON cart.item_id = items.id
      ''');
      
      // Return quantities to stock for each item
      for (var item in cartItems) {
        int itemId = item['item_id'];
        int quantity = item['quantity'];
        int currentStock = item['stock'];
        
        await _databaseHelper.updateStock(itemId, currentStock + quantity);
      }
      
      await _databaseHelper.clearCart();
      await loadCartItems();
      
      // Refresh product list in HomeController to reflect stock changes
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadProducts();
      }
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  void _calculateTotal() {
    double total = 0.0;
    for (var item in cartItems) {
      if (item.price != null) {
        total += item.price! * item.quantity;
      }
    }
    totalAmount.value = total;
  }
}
