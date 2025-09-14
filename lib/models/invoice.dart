import 'package:ebook_app/models/item.dart';

// class Invoice {
//   final List<Item> items;
//   final DateTime date;
//   final String customerName; // أضف هذا الحقل

//   Invoice({
//     required this.items,
//     required this.date,
//     required this.customerName, // اجعله مطلوب
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'date': date.toIso8601String(),
//       'items': items.map((item) => item.toMap()).toList(),
//       'customerName': customerName, // حفظ الاسم في القاعدة
//     };
//   }

//   factory Invoice.fromMap(Map<String, dynamic> map) {
//     return Invoice(
//       date: DateTime.parse(map['date']),
//       items: (map['items'] as List)
//           .map((itemMap) => Item.fromMap(itemMap))
//           .toList(),
//       customerName: map['customerName'] ?? '', // قراءة الاسم من القاعدة
//     );
//   }
// }

class Invoice {
  final List<Item> items;
  final DateTime date;
  final String customerName; // ✅ أضفنا هذا الحقل

  Invoice({
    required this.items,
    required this.date,
    required this.customerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'customerName': customerName,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((itemMap) => Item.fromMap(itemMap))
          .toList(),
      customerName: map['customerName'] ?? 'زبون غير معروف',
    );
  }
}
