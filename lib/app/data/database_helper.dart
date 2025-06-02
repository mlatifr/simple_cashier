import 'package:simple_cashier/app/modules/home/model/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _isInitialized = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    // Check if initial data has been inserted
    if (!_isInitialized) {
      await _insertInitialData();
      _isInitialized = true;
    }

    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'simple_cashier.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        isLogin INTEGER NOT NULL
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL
      )
    ''');

    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');

    // Create cart table to manage items in cart
    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Create transactions table to relate items and customers
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        item_id INTEGER,
        quantity INTEGER NOT NULL,
        transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (customer_id) REFERENCES customers (id),
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');
  }

  // Insert initial data when app first opens
  Future<void> _insertInitialData() async {
    Database db = await database;

    // Check if items table is empty
    for (var product in initialProducts) {
      // Check if product already exists
      List<Map<String, dynamic>> existingProduct = await db.query(
        'items',
        where: 'code = ?',
        whereArgs: [product.code],
      );

      // Only insert if product doesn't exist
      if (existingProduct.isEmpty) {
        await db.insert(
            'items',
            {
              'code': product.code,
              'name': product.name,
              'price': product.price,
              'stock': product.stock,
            },
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    Database db = await database;
    return await db.insert('users', user,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateLoginStatus(String username, int status) async {
    Database db = await database;
    return await db.update(
      'users',
      {'isLogin': status},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> readIsLogin() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'users',
      columns: ['isLogin'],
      where: 'isLogin = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['isLogin'] == 1;
    }
    return false;
  }

  // Logout method to reset login status for all users
  Future<int> logout() async {
    Database db = await database;
    return await db.update(
      'users',
      {'isLogin': 0},
      where: 'isLogin = ?',
      whereArgs: [1],
    );
  }

  // Methods for items
  Future<int> insertItem(Map<String, dynamic> item) async {
    Database db = await database;
    return await db.insert('items', item,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Methods for customers
  Future<int> insertCustomer(Map<String, dynamic> customer) async {
    Database db = await database;
    return await db.insert('customers', customer,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Methods for transactions
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    Database db = await database;
    return await db.insert('transactions', transaction);
  }

  // Initial product data
  static List<Product> initialProducts = [
    Product(code: 'P001', name: 'Rice 5kg', price: 58000, stock: 150),
    Product(code: 'P002', name: 'Cooking Oil 1L', price: 14000, stock: 140),
    Product(code: 'P003', name: 'Sugar 1kg', price: 12500, stock: 145),
    Product(code: 'P004', name: 'Instant Noodles', price: 3500, stock: 200),
    Product(code: 'P005', name: 'Eggs (12pcs)', price: 28000, stock: 130),
    Product(code: 'P006', name: 'Milk 1L', price: 15000, stock: 135),
    Product(code: 'P007', name: 'Bread', price: 12000, stock: 125),
    Product(code: 'P008', name: 'Coffee 200g', price: 45000, stock: 120),
    Product(code: 'P009', name: 'Tea Bags (25pcs)', price: 8500, stock: 140),
    Product(code: 'P010', name: 'Salt 500g', price: 5000, stock: 150),
    Product(code: 'P011', name: 'Flour 1kg', price: 12000, stock: 140),
    Product(code: 'P012', name: 'Dish Soap', price: 10000, stock: 130),
    Product(code: 'P013', name: 'Toothpaste', price: 15000, stock: 125),
    Product(code: 'P014', name: 'Shampoo 250ml', price: 25000, stock: 120),
    Product(code: 'P015', name: 'Soap Bar', price: 5000, stock: 145),
    Product(code: 'P016', name: 'Tissue Paper', price: 8000, stock: 150),
    Product(code: 'P017', name: 'Detergent 1kg', price: 28000, stock: 130),
    Product(code: 'P018', name: 'Soy Sauce 500ml', price: 15000, stock: 135),
    Product(code: 'P019', name: 'Chili Sauce', price: 12000, stock: 140),
    Product(code: 'P020', name: 'Tomato Sauce', price: 12000, stock: 140),
    Product(code: 'P021', name: 'Biscuits', price: 8500, stock: 160),
    Product(code: 'P022', name: 'Chocolate Bar', price: 12500, stock: 145),
    Product(code: 'P023', name: 'Candy Pack', price: 5000, stock: 170),
    Product(code: 'P024', name: 'Chips', price: 9500, stock: 155),
    Product(code: 'P025', name: 'Peanuts 250g', price: 15000, stock: 140),
    Product(code: 'P026', name: 'Sardines Can', price: 8500, stock: 145),
    Product(code: 'P027', name: 'Tuna Can', price: 12000, stock: 140),
    Product(code: 'P028', name: 'Chicken Stock', price: 5000, stock: 160),
    Product(code: 'P029', name: 'Garlic 250g', price: 8000, stock: 140),
    Product(code: 'P030', name: 'Onion 500g', price: 12000, stock: 135),
    Product(code: 'P031', name: 'Potato 1kg', price: 15000, stock: 130),
    Product(code: 'P032', name: 'Carrot 500g', price: 10000, stock: 135),
    Product(code: 'P033', name: 'Tofu Pack', price: 8000, stock: 140),
    Product(code: 'P034', name: 'Tempeh Pack', price: 5000, stock: 145),
    Product(code: 'P035', name: 'Chicken 1kg', price: 35000, stock: 125),
    Product(code: 'P036', name: 'Fish 1kg', price: 40000, stock: 120),
    Product(code: 'P037', name: 'Shrimp 500g', price: 45000, stock: 115),
    Product(code: 'P038', name: 'Beef 1kg', price: 120000, stock: 115),
    Product(code: 'P039', name: 'Butter 250g', price: 15000, stock: 130),
    Product(code: 'P040', name: 'Cheese 250g', price: 25000, stock: 125),
    Product(code: 'P041', name: 'Yogurt 500ml', price: 18000, stock: 120),
    Product(code: 'P042', name: 'Orange Juice 1L', price: 20000, stock: 125),
    Product(code: 'P043', name: 'Mineral Water 1.5L', price: 6000, stock: 200),
    Product(code: 'P044', name: 'Soda Can', price: 7500, stock: 160),
    Product(code: 'P045', name: 'Paper Towel', price: 12000, stock: 140),
    Product(code: 'P046', name: 'Garbage Bags', price: 15000, stock: 135),
    Product(code: 'P047', name: 'Air Freshener', price: 22000, stock: 125),
    Product(code: 'P048', name: 'Matches', price: 3000, stock: 180),
    Product(code: 'P049', name: 'Light Bulb', price: 15000, stock: 130),
    Product(code: 'P050', name: 'Batteries AA 4pcs', price: 18000, stock: 135),
  ];

// Cart methods
  Future<List<Map<String, dynamic>>> getCartItems() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT cart.id, cart.item_id, cart.quantity, items.code, items.name, items.price
      FROM cart
      INNER JOIN items ON cart.item_id = items.id
    ''');
  }

  Future<int> addToCart(int itemId, int quantity) async {
    Database db = await database;

    // Check if item already exists in cart
    List<Map<String, dynamic>> existingItem = await db.query(
      'cart',
      where: 'item_id = ?',
      whereArgs: [itemId],
    );

    if (existingItem.isNotEmpty) {
      // Update quantity if item already in cart
      int currentQuantity = existingItem.first['quantity'];
      return await db.update(
        'cart',
        {'quantity': currentQuantity + quantity},
        where: 'item_id = ?',
        whereArgs: [itemId],
      );
    } else {
      // Add new item to cart
      return await db.insert(
        'cart',
        {'item_id': itemId, 'quantity': quantity},
      );
    }
  }

  Future<int> updateCartItemQuantity(int cartId, int quantity) async {
    Database db = await database;
    return await db.update(
      'cart',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> removeFromCart(int cartId) async {
    Database db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<int> clearCart() async {
    Database db = await database;
    return await db.delete('cart');
  }
}
