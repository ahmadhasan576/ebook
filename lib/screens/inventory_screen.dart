import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/item.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Item> items = [];

  Future<void> fetchItems() async {
    final fetchedItems = await DatabaseHelper.instance.getAllItems();
    setState(() {
      items = fetchedItems;
    });
  }

  Future<void> addItemDialog() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة مادة جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم المادة'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('حفظ'),

              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (name.isNotEmpty && price > 0 && quantity > 0) {
                  // تحقق إذا المادة موجودة
                  final existingItem = items.firstWhere(
                    (item) => item.name == name,
                    orElse: () => Item(id: -1, name: '', price: 0, quantity: 0),
                  );

                  if (existingItem.id != -1) {
                    // تحديث الكمية بدل الإضافة
                    final updatedItem = Item(
                      id: existingItem.id,
                      name: existingItem.name,
                      price: existingItem.price,
                      quantity: existingItem.quantity + quantity,
                    );
                    await DatabaseHelper.instance.updateItem(updatedItem);
                  } else {
                    // مادة جديدة
                    final newItem = Item(
                      name: name,
                      price: price,
                      quantity: quantity,
                    );
                    await DatabaseHelper.instance.insertItem(newItem);
                  }

                  fetchItems();
                }
                Navigator.pop(context);
              },

              // onPressed: () async {
              //   final name = nameController.text.trim();
              //   final price = double.tryParse(priceController.text) ?? 0.0;
              //   final quantity = int.tryParse(quantityController.text) ?? 0;

              //   if (name.isNotEmpty && price > 0 && quantity > 0) {
              //     final newItem = Item(
              //       name: name,
              //       price: price,
              //       quantity: quantity,
              //     );
              //     await DatabaseHelper.instance.insertItem(newItem);
              //     fetchItems();
              //   }
              //   Navigator.pop(context);
              // },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editItemDialog(Item item) async {
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل ${item.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر'),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الكمية'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('حفظ'),
              onPressed: () async {
                final price =
                    double.tryParse(priceController.text) ?? item.price;
                final quantity =
                    int.tryParse(quantityController.text) ?? item.quantity;

                final updatedItem = Item(
                  id: item.id,
                  name: item.name, // الاسم لا يتغير
                  price: price,
                  quantity: quantity,
                );

                await DatabaseHelper.instance.updateItem(updatedItem);
                fetchItems();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المواد المخزنة'),
          backgroundColor: Colors.teal,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // الخلفية
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'إضافة مادة',
                  onPressed: addItemDialog,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: items.isEmpty
              ? const Center(child: Text('لا توجد مواد مضافة بعد.'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'السعر: ${item.price} ل.س - الكمية: ${item.quantity}',
                        ),
                        leading: const Icon(Icons.inventory),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editItemDialog(item);
                            } else if (value == 'delete') {
                              DatabaseHelper.instance.deleteItem(item.id!);
                              fetchItems();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('تعديل'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('حذف'),
                            ),
                          ],
                        ),
                      ),

                      // ListTile(
                      //   title: Text(item.name),
                      //   subtitle: Text(
                      //     'السعر: ${item.price} ل.س - الكمية: ${item.quantity}',
                      //   ),
                      //   leading: const Icon(Icons.inventory),
                      //   trailing: PopupMenuButton<String>(
                      //     onSelected: (value) async {
                      //       if (value == 'edit') {
                      //         editItemDialog(item);
                      //       } else if (value == 'delete') {
                      //         await DatabaseHelper.instance.deleteItem(
                      //           item.id!,
                      //         );
                      //         fetchItems();
                      //       }
                      //     },
                      //     itemBuilder: (context) => [
                      //       const PopupMenuItem(
                      //         value: 'edit',
                      //         child: Text("تعديل"),
                      //       ),
                      //       const PopupMenuItem(
                      //         value: 'delete',
                      //         child: Text("حذف"),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // ListTile(
                      //   title: Text(item.name),
                      //   subtitle: Text(
                      //     'السعر: ${item.price} ل.س - الكمية: ${item.quantity}',
                      //   ),
                      //   leading: const Icon(Icons.inventory),
                      // ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
