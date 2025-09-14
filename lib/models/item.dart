// // lib/models/item.dart
// class Item {
//   final String name;
//   final double price;
//   final int quantity;

//   Item({required this.name, required this.price, required this.quantity});

//   Map<String, dynamic> toMap() {
//     return {'name': name, 'price': price, 'quantity': quantity};
//   }

//   factory Item.fromMap(Map<String, dynamic> map) {
//     return Item(
//       name: map['name'],
//       price: (map['price'] as num).toDouble(),
//       quantity: (map['quantity'] as num).toInt(),
//     );
//   }
// }
// __________________________________________________
// class Item {
//   final String name;
//   final int quantity;
//   final double price;

//   Item({required this.name, required this.quantity, required this.price});

//   Map<String, dynamic> toMap() {
//     return {'name': name, 'quantity': quantity, 'price': price};
//   }

//   factory Item.fromMap(Map<String, dynamic> map) {
//     return Item(
//       name: map['name'],
//       quantity: map['quantity'],
//       price: (map['price'] as num).toDouble(),
//     );
//   }
// }

// __________________________________
// class Item {
//   final int? id; // nullable لأنه ينشأ تلقائي من قاعدة البيانات
//   final String name;
//   final double price;
//   final int quantity;

//   Item({
//     this.id,
//     required this.name,
//     required this.price,
//     required this.quantity,
//   });

//   // للتحويل من Map (SQLite) إلى Item
//   factory Item.fromMap(Map<String, dynamic> map) {
//     return Item(
//       id: map['id'],
//       name: map['name'],
//       price: map['price'],
//       quantity: map['quantity'],
//     );
//   }

//   // للتحويل من Item إلى Map (SQLite)
//   Map<String, dynamic> toMap() {
//     return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
//   }
// }

class Item {
  final int? id; // يجي من Sembast key
  final String name;
  final double price;
  final int quantity;

  Item({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory Item.fromMap(Map<String, dynamic> map, {int? id}) {
    return Item(
      id: id,
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'quantity': quantity};
  }
}
