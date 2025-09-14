// import 'package:flutter/material.dart';
// import '../db/database_helper.dart';
// import '../models/item.dart';
// import '../models/invoice.dart';

// class CreateInvoiceScreen extends StatefulWidget {
//   const CreateInvoiceScreen({super.key});

//   @override
//   State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
// }

// class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
//   List<Item> allItems = [];
//   List<Item> selectedItems = [];

//   bool isLoading = true;

//   final TextEditingController customerNameController = TextEditingController();
//   final TextEditingController searchController = TextEditingController();
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     loadItemsFromDB();
//   }

//   @override
//   void dispose() {
//     customerNameController.dispose();
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<void> loadItemsFromDB() async {
//     final items = await DatabaseHelper.instance.getAllItems();
//     setState(() {
//       allItems = items;
//       isLoading = false;
//     });
//   }

//   void addItem(Item item) {
//     if (!selectedItems.any((i) => i.name == item.name)) {
//       setState(() {
//         selectedItems.add(
//           Item(name: item.name, quantity: 1, price: item.price),
//         );
//       });
//     }
//   }

//   void removeItem(Item item) {
//     setState(() {
//       selectedItems.removeWhere((i) => i.name == item.name);
//     });
//   }

//   void updateQuantity(Item item, int newQuantity) {
//     if (newQuantity <= 0) return;

//     final storedItem = allItems.firstWhere(
//       (element) => element.name == item.name,
//     );

//     if (newQuantity > storedItem.quantity) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'لا يمكن إضافة كمية أكثر من الكمية الموجودة في المخزون (${storedItem.quantity})',
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       final index = selectedItems.indexWhere((i) => i.name == item.name);
//       if (index != -1) {
//         selectedItems[index] = Item(
//           name: item.name,
//           quantity: newQuantity,
//           price: item.price,
//         );
//       }
//     });
//   }

//   double get total {
//     return selectedItems.fold(
//       0.0,
//       (sum, item) => sum + item.price * item.quantity,
//     );
//   }

//   void saveInvoice() async {
//     final customerName = customerNameController.text.trim();

//     if (customerName.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('يرجى إدخال اسم الزبون')));
//       return;
//     }

//     if (selectedItems.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('الفاتورة فارغة')));
//       return;
//     }

//     for (var invoiceItem in selectedItems) {
//       final index = allItems.indexWhere((i) => i.name == invoiceItem.name);
//       if (index != -1) {
//         int updatedQuantity = allItems[index].quantity - invoiceItem.quantity;
//         if (updatedQuantity < 0) updatedQuantity = 0;

//         allItems[index] = Item(
//           name: allItems[index].name,
//           price: allItems[index].price,
//           quantity: updatedQuantity,
//         );

//         await DatabaseHelper.instance.updateItem(allItems[index]);
//       }
//     }

//     final invoice = Invoice(
//       items: selectedItems,
//       date: DateTime.now(),
//       customerName: customerName,
//     );

//     await DatabaseHelper.instance.insertInvoice(invoice);

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('تم حفظ الفاتورة بنجاح')));
//     Navigator.pop(context);
//   }
//   // نفس الاستيرادات والبيانات والوظائف كما هي بدون تغيير ...

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('إنشاء فاتورة')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final filteredItems = allItems.where((item) {
//       return item.name.toLowerCase().contains(searchQuery.toLowerCase());
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('إنشاء فاتورة'),
//         backgroundColor: Colors.teal,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // اسم الزبون
//             TextField(
//               controller: customerNameController,
//               decoration: InputDecoration(
//                 labelText: 'اسم الزبون',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 prefixIcon: const Icon(Icons.person),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // البحث
//             TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'بحث عن مادة',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 prefixIcon: const Icon(Icons.search),
//                 suffixIcon: searchQuery.isNotEmpty
//                     ? IconButton(
//                         icon: const Icon(Icons.clear),
//                         onPressed: () {
//                           searchController.clear();
//                           setState(() {
//                             searchQuery = '';
//                           });
//                         },
//                       )
//                     : null,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   searchQuery = value.trim();
//                 });
//               },
//             ),
//             const SizedBox(height: 16),

//             // المواد المتوفرة
//             const Text(
//               'المواد المتوفرة',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: filteredItems.length,
//                 itemBuilder: (context, index) {
//                   final item = filteredItems[index];
//                   final isSelected = selectedItems.any(
//                     (selected) => selected.name == item.name,
//                   );

//                   return Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: ListTile(
//                       title: Text(item.name),
//                       subtitle: Text(
//                         'السعر: ${item.price.toStringAsFixed(2)} د.ع - المتوفر: ${item.quantity}',
//                       ),
//                       trailing: isSelected
//                           ? const Icon(Icons.check, color: Colors.green)
//                           : ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.teal,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: const Text('إضافة'),
//                               onPressed: item.quantity > 0
//                                   ? () => addItem(item)
//                                   : null,
//                             ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 12),
//             const Divider(),

//             // المواد المختارة
//             const Text(
//               'المواد المختارة',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: selectedItems.isEmpty
//                   ? const Text('لم تقم بإضافة أي مادة بعد.')
//                   : ListView.builder(
//                       itemCount: selectedItems.length,
//                       itemBuilder: (context, index) {
//                         final item = selectedItems[index];

//                         return Card(
//                           color: Colors.grey[100],
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: ListTile(
//                             leading: IconButton(
//                               icon: const Icon(
//                                 Icons.remove_circle,
//                                 color: Colors.red,
//                               ),
//                               onPressed: () => removeItem(item),
//                             ),
//                             title: Text(item.name),
//                             subtitle: Text(
//                               'السعر: ${item.price.toStringAsFixed(2)} د.ع',
//                             ),
//                             trailing: SizedBox(
//                               width: 130,
//                               child: Row(
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(Icons.remove),
//                                     onPressed: () =>
//                                         updateQuantity(item, item.quantity - 1),
//                                   ),
//                                   Text(item.quantity.toString()),
//                                   IconButton(
//                                     icon: const Icon(Icons.add),
//                                     onPressed: () =>
//                                         updateQuantity(item, item.quantity + 1),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ),

//             const Divider(),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               child: Text(
//                 'المجموع: ${total.toStringAsFixed(2)} د.ع',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 icon: const Icon(Icons.save),
//                 label: const Text('حفظ الفاتورة'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: saveInvoice,
//               ),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/item.dart';
import '../models/invoice.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  List<Item> allItems = [];
  List<Item> selectedItems = [];
  List<String> customerNames = []; // ✅ أسماء الزبائن من الفواتير السابقة

  bool isLoading = true;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadItemsFromDB();
    loadCustomerNames(); // ✅ تحميل أسماء الزبائن
  }

  @override
  void dispose() {
    customerNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadItemsFromDB() async {
    final items = await DatabaseHelper.instance.getAllItems();
    setState(() {
      allItems = items;
      isLoading = false;
    });
  }

  Future<void> loadCustomerNames() async {
    final invoices = await DatabaseHelper.instance.getAllInvoices();
    setState(() {
      customerNames = invoices
          .map((inv) => inv.customerName)
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
    });
  }

  void addItem(Item item) {
    if (!selectedItems.any((i) => i.name == item.name)) {
      setState(() {
        selectedItems.add(
          Item(name: item.name, quantity: 1, price: item.price),
        );
      });
    }
  }

  void removeItem(Item item) {
    setState(() {
      selectedItems.removeWhere((i) => i.name == item.name);
    });
  }

  void updateQuantity(Item item, int newQuantity) {
    if (newQuantity <= 0) return;

    final storedItem = allItems.firstWhere(
      (element) => element.name == item.name,
    );

    if (newQuantity > storedItem.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن إضافة كمية أكثر من الكمية الموجودة في المخزون (${storedItem.quantity})',
          ),
        ),
      );
      return;
    }

    setState(() {
      final index = selectedItems.indexWhere((i) => i.name == item.name);
      if (index != -1) {
        selectedItems[index] = Item(
          name: item.name,
          quantity: newQuantity,
          price: item.price,
        );
      }
    });
  }

  double get total {
    return selectedItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  void saveInvoice() async {
    final customerName = customerNameController.text.trim();

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى إدخال اسم الزبون')));
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الفاتورة فارغة')));
      return;
    }

    for (var invoiceItem in selectedItems) {
      final index = allItems.indexWhere((i) => i.name == invoiceItem.name);
      if (index != -1) {
        int updatedQuantity = allItems[index].quantity - invoiceItem.quantity;
        if (updatedQuantity < 0) updatedQuantity = 0;

        allItems[index] = Item(
          name: allItems[index].name,
          price: allItems[index].price,
          quantity: updatedQuantity,
        );

        await DatabaseHelper.instance.updateItem(allItems[index]);
      }
    }

    final invoice = Invoice(
      items: selectedItems,
      date: DateTime.now(),
      customerName: customerName,
    );

    await DatabaseHelper.instance.insertInvoice(invoice);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم حفظ الفاتورة بنجاح')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('إنشاء فاتورة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filteredItems = allItems.where((item) {
      return item.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Autocomplete لاسم الزبون
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return customerNames.where(
                  (name) => name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    controller.text = customerNameController.text;
                    controller.selection = customerNameController.selection;

                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'اسم الزبون',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (value) {
                        customerNameController.text = value;
                        customerNameController.selection = controller.selection;
                      },
                    );
                  },
              onSelected: (String selection) {
                customerNameController.text = selection;
              },
            ),
            const SizedBox(height: 16),

            // البحث
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'بحث عن مادة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 16),

            // المواد المتوفرة
            const Text(
              'المواد المتوفرة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = selectedItems.any(
                    (selected) => selected.name == item.name,
                  );

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        'السعر: ${item.price.toStringAsFixed(2)} د.ع - المتوفر: ${item.quantity}',
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('إضافة'),
                              onPressed: item.quantity > 0
                                  ? () => addItem(item)
                                  : null,
                            ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // المواد المختارة
            const Text(
              'المواد المختارة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: selectedItems.isEmpty
                  ? const Text('لم تقم بإضافة أي مادة بعد.')
                  : ListView.builder(
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];

                        return Card(
                          color: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => removeItem(item),
                            ),
                            title: Text(item.name),
                            subtitle: Text(
                              'السعر: ${item.price.toStringAsFixed(2)} د.ع',
                            ),
                            trailing: SizedBox(
                              width: 130,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () =>
                                        updateQuantity(item, item.quantity - 1),
                                  ),
                                  Text(item.quantity.toString()),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () =>
                                        updateQuantity(item, item.quantity + 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'المجموع: ${total.toStringAsFixed(2)} د.ع',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('حفظ الفاتورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saveInvoice,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
