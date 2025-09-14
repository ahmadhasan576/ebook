// lib/db/database_helper.dart
import 'dart:io' show Directory;
import 'package:ebook_app/models/invoice.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart'; // متوفرة تلقائيًا
// import 'package:sembast/sembast_web.dart'; // متوفرة تلقائيًا
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import 'package:sembast_web/sembast_web.dart';

// class DatabaseHelper {
//   static final DatabaseHelper instance = DatabaseHelper._internal();
//   static Database? _db;

//   final _store = intMapStoreFactory.store('items');

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     return await _initDatabase();
//   }

//   Future<Database> _initDatabase() async {
//     DatabaseFactory dbFactory;
//     String dbPath;

//     if (kIsWeb) {
//       // للويب: يستخدم IndexedDB
//       dbFactory = databaseFactoryWeb;
//       dbPath = 'warehouse.db'; // يتم تخزينه تلقائيًا في المتصفح
//     } else {
//       // لأندرويد/ويندوز/iOS
//       Directory appDocDir = await getApplicationDocumentsDirectory();
//       dbPath = join(appDocDir.path, 'warehouse.db');
//       dbFactory = databaseFactoryIo;
//     }

//     _db = await dbFactory.openDatabase(dbPath);
//     return _db!;
//   }

//   Future<void> insertItem(Item item) async {
//     final db = await database;
//     await _store.add(db, item.toMap());
//   }

//   Future<List<Item>> getAllItems() async {
//     final db = await database;
//     final snapshots = await _store.find(db);
//     return snapshots.map((e) => Item.fromMap(e.value)).toList();
//   }

//   // داخل DatabaseHelper
//   final _invoiceStore = intMapStoreFactory.store('invoices');

//   Future<void> insertInvoice(Invoice invoice) async {
//     final db = await database;
//     await _invoiceStore.add(db, invoice.toMap());
//   }

//   Future<List<Invoice>> getAllInvoices() async {
//     final db = await database;
//     final snapshots = await _invoiceStore.find(db);
//     return snapshots.map((e) => Invoice.fromMap(e.value)).toList();
//   }

//   Future<void> updateItem(Item item) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('name', item.name));
//     await _store.update(db, item.toMap(), finder: finder);
//   }
// }
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  final _store = intMapStoreFactory.store('items');
  final _invoiceStore = intMapStoreFactory.store('invoices');

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    return await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory dbFactory;
    String dbPath;

    if (kIsWeb) {
      dbFactory = databaseFactoryWeb;
      dbPath = 'warehouse.db';
    } else {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      dbPath = join(appDocDir.path, 'warehouse.db');
      dbFactory = databaseFactoryIo;
    }

    _db = await dbFactory.openDatabase(dbPath);
    return _db!;
  }

  // ✅ إضافة مادة (مع التحقق إن كانت موجودة بنفس الاسم)
  Future<void> insertItem(Item item) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('name', item.name));
    final existing = await _store.findFirst(db, finder: finder);

    if (existing != null) {
      // إذا المادة موجودة → حدث الكمية
      final existingItem = Item.fromMap(existing.value, id: existing.key);
      final updatedItem = Item(
        id: existingItem.id,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + item.quantity,
      );
      await _store.record(existing.key).put(db, updatedItem.toMap());
    } else {
      // مادة جديدة
      await _store.add(db, item.toMap());
    }
  }

  // ✅ جلب كل المواد
  Future<List<Item>> getAllItems() async {
    final db = await database;
    final snapshots = await _store.find(db);
    return snapshots.map((e) => Item.fromMap(e.value, id: e.key)).toList();
  }

  // ✅ تحديث مادة
  Future<void> updateItem(Item item) async {
    final db = await database;
    if (item.id != null) {
      await _store.record(item.id!).put(db, item.toMap());
    }
  }

  // ✅ حذف مادة
  Future<void> deleteItem(int id) async {
    final db = await database;
    await _store.record(id).delete(db);
  }

  // ✅ الفواتير
  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await _invoiceStore.add(db, invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final snapshots = await _invoiceStore.find(db);
    return snapshots.map((e) => Invoice.fromMap(e.value)).toList();
  }
}
