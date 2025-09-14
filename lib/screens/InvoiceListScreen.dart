import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/database_helper.dart';
import '../models/invoice.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Invoice> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final allInvoices = await DatabaseHelper.instance.getAllInvoices();
    setState(() {
      invoices = allInvoices;
      isLoading = false;
    });
  }

  double calculateTotal(Invoice invoice) {
    return invoice.items.fold(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  Future<pw.Font> loadArabicFont() async {
    try {
      final ByteData fontData = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      return pw.Font.ttf(fontData.buffer.asByteData());
    } catch (e) {
      debugPrint('خط عربي غير موجود، سيتم استخدام الخط الافتراضي: $e');
      return pw.Font.helvetica();
    }
  }

  Future<pw.Document> buildInvoicePdf(
    Invoice invoice,
    pw.Font arabicFont,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "فاتورة",
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "اسم الزبون: ${invoice.customerName}",
                  style: pw.TextStyle(font: arabicFont),
                ),
                pw.Text(
                  "التاريخ: ${invoice.date.toLocal().toString().split(' ')[0]}",
                  style: pw.TextStyle(font: arabicFont),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "المواد:",
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Table.fromTextArray(
                  headers: ["الاسم", "الكمية", "السعر للوحدة", "الإجمالي"],
                  data: invoice.items.map((item) {
                    final total = item.price * item.quantity;
                    return [
                      item.name,
                      item.quantity.toString(),
                      item.price.toStringAsFixed(2),
                      total.toStringAsFixed(2),
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  cellStyle: pw.TextStyle(font: arabicFont),
                ),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "المجموع: ${calculateTotal(invoice).toStringAsFixed(2)} ل.س",
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    return pdf;
  }

  /// ✅ طلب إذن التخزين (للأندرويد فقط - مطلوب لحفظ في التنزيلات)
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid && !kIsWeb) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true;
  }

  /// ✅ إنشاء ملف PDF في مجلد التنزيلات العام (لعرضه في مدير الملفات)
  Future<File> generateInvoicePdf(String customerName, pw.Document pdf) async {
    final bytes = await pdf.save();

    Directory dir;
    if (Platform.isAndroid && !kIsWeb) {
      // ✅ حفظ في مجلد التنزيلات العام — ليظهر في مدير الملفات
      dir = Directory('/storage/emulated/0/Download');
    } else {
      // للآيفون أو الويب أو الأنظمة الأخرى
      dir = await getApplicationDocumentsDirectory();
    }

    String fileName = "invoice_$customerName.pdf";
    File file = File("${dir.path}/$fileName");
    int counter = 1;

    // تجنب التكرار: إذا كان الملف موجودًا، نضيف رقمًا متسلسلًا
    while (await file.exists()) {
      fileName = "invoice_${customerName}_$counter.pdf";
      file = File("${dir.path}/$fileName");
      counter++;
    }

    await file.writeAsBytes(bytes);
    return file;
  }

  /// ✅ معاينة PDF — يطلب الصلاحية أولًا إذا لزم الأمر
  Future<void> previewPdf(Invoice invoice) async {
    final arabicFont = await loadArabicFont();
    final pdf = await buildInvoicePdf(invoice, arabicFont);

    if (!kIsWeb) {
      if (!await requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يمكن فتح الملف: صلاحية التخزين مرفوضة"),
          ),
        );
        return;
      }

      final file = await generateInvoicePdf(invoice.customerName, pdf);
      await OpenFilex.open(file.path);
    } else {
      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    }
  }

  /// ✅ مشاركة PDF — يطلب الصلاحية أولًا إذا لزم الأمر
  Future<void> shareInvoicePdf(Invoice invoice) async {
    final arabicFont = await loadArabicFont();
    final pdf = await buildInvoicePdf(invoice, arabicFont);

    if (!kIsWeb) {
      if (!await requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يمكن مشاركة الملف: صلاحية التخزين مرفوضة"),
          ),
        );
        return;
      }

      final file = await generateInvoicePdf(invoice.customerName, pdf);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: "application/pdf")],
        text:
            "فاتورة ${invoice.customerName} - المجموع: ${calculateTotal(invoice).toStringAsFixed(2)} ل.س",
      );
    } else {
      final pdfBytes = await pdf.save();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "invoice_${invoice.customerName}.pdf",
      );
    }
  }

  /// ✅ حفظ وفتح PDF مع إشعار وتلميح لعرض الملف
  Future<void> saveAndOpenInvoicePdf(Invoice invoice) async {
    final arabicFont = await loadArabicFont();
    final pdf = await buildInvoicePdf(invoice, arabicFont);

    if (!kIsWeb) {
      if (!await requestStoragePermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يمكن حفظ الملف: صلاحية التخزين مرفوضة"),
          ),
        );
        return;
      }

      final file = await generateInvoicePdf(invoice.customerName, pdf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم حفظ الفاتورة باسم:\n${file.path.split("/").last}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'عرض',
              textColor: Colors.yellow,
              onPressed: () => OpenFilex.open(file.path),
            ),
          ),
        );
      }
    }
  }

  void showInvoiceDetails(Invoice invoice) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.ltr,
        child: AlertDialog(
          title: Text('فاتورة - ${invoice.customerName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التاريخ: ${invoice.date.toLocal().toString().split(' ')[0]}',
                ),
                if (invoice.customerName.isNotEmpty)
                  Text('اسم الزبون: ${invoice.customerName}'),
                const SizedBox(height: 12),
                const Text(
                  'المواد:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ...invoice.items.map(
                  (item) => Text(
                    '${item.name} - الكمية: ${item.quantity} - السعر للوحدة: ${item.price.toStringAsFixed(2)}',
                  ),
                ),
                const Divider(),
                Text(
                  'المجموع: ${calculateTotal(invoice).toStringAsFixed(2)} ل.س',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('معاينة PDF'),
              onPressed: () async {
                Navigator.pop(context);
                await previewPdf(invoice);
              },
            ),
            TextButton(
              child: const Text('مشاركة PDF'),
              onPressed: () async {
                Navigator.pop(context);
                await shareInvoicePdf(invoice);
              },
            ),
            if (!kIsWeb)
              TextButton(
                child: const Text('حفظ وفتح PDF'),
                onPressed: () async {
                  Navigator.pop(context);
                  await saveAndOpenInvoicePdf(invoice);
                },
              ),
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الفواتير'),
          backgroundColor: Colors.teal,
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : invoices.isEmpty
            ? const Center(child: Text('لا توجد فواتير محفوظة'))
            : ListView.builder(
                itemCount: invoices.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    child: ListTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Colors.teal,
                      ),
                      title: Text(
                        invoice.customerName.isNotEmpty
                            ? 'الزبون: ${invoice.customerName}'
                            : 'زبون غير معروف',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'التاريخ: ${invoice.date.toLocal().toString().split(' ')[0]}',
                      ),
                      trailing: Text(
                        '${calculateTotal(invoice).toStringAsFixed(2)} ل.س',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      onTap: () => showInvoiceDetails(invoice),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
