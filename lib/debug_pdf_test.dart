import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/services.dart';

class DebugPdfTestPage extends StatelessWidget {
  const DebugPdfTestPage({super.key});

  Future<void> _createSaveOpenShare() async {
    try {
      print("🔸 START create PDF");
      final pdf = pw.Document();
      // try a very simple page (no external font)
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(child: pw.Text("تجربة إنشاء ملف PDF")),
        ),
      );

      final bytes = await pdf.save();
      print("🔸 PDF bytes length = ${bytes.length}");

      // Documents dir
      final docDir = await getApplicationDocumentsDirectory();
      final docPath = '${docDir.path}/debug_invoice.pdf';
      final docFile = File(docPath);
      await docFile.writeAsBytes(bytes);
      print(
        "🔸 Saved docFile at: $docPath (exists=${await docFile.exists()}, size=${await docFile.length()})",
      );

      // Temp/cache dir
      final tmpDir = await getTemporaryDirectory();
      final tmpPath = '${tmpDir.path}/debug_invoice_tmp.pdf';
      final tmpFile = File(tmpPath);
      await tmpFile.writeAsBytes(bytes);
      print(
        "🔸 Saved tmpFile at: $tmpPath (exists=${await tmpFile.exists()}, size=${await tmpFile.length()})",
      );

      // Try to open the tmp file with system viewer
      print("🔸 Trying to open tmp file...");
      final openRes = await OpenFilex.open(tmpPath);
      print("🔸 OpenFilex result: $openRes");

      // Then try share
      print("🔸 Trying to share tmp file...");
      await Share.shareXFiles([XFile(tmpPath)], text: "فاتورة تجريبية");
      print("🔸 Share call completed.");
    } catch (e, s) {
      print("❌ ERROR in createSaveOpenShare -> $e");
      print(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Debug PDF Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: _createSaveOpenShare,
          child: const Text("Create, Open & Share PDF (Debug)"),
        ),
      ),
    );
  }
}
