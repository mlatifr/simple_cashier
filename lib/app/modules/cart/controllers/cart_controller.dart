import 'package:get/get.dart';
import 'package:simple_cashier/app/data/database_helper.dart';
import 'package:simple_cashier/app/modules/cart/models/cart_item_model.dart';

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

  Future<void> addToCart(int itemId, int quantity) async {
    try {
      await _databaseHelper.addToCart(itemId, quantity);
      await loadCartItems();
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }

  Future<void> increaseQuantity(CartItem item) async {
    try {
      if (item.id != null) {
        await _databaseHelper.updateCartItemQuantity(item.id!, item.quantity + 1);
        await loadCartItems();
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(CartItem item) async {
    try {
      if (item.id != null) {
        if (item.quantity > 1) {
          await _databaseHelper.updateCartItemQuantity(item.id!, item.quantity - 1);
        } else {
          await _databaseHelper.removeFromCart(item.id!);
        }
        await loadCartItems();
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  Future<void> removeItem(int cartId) async {
    try {
      await _databaseHelper.removeFromCart(cartId);
      await loadCartItems();
    } catch (e) {
      print('Error removing item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _databaseHelper.clearCart();
      await loadCartItems();
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
