import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../app/data.dart';

class PDFGenerator {
  static Future<void> generateAdminReport({
    required BuildContext context,
    required List<Aspirasi> aspirasiList,
    required String adminName,
  }) async {
    // SIMPLE LOADING
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final pdf = pw.Document();

      // HALAMAN 1 - SANGAT SIMPLE
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'LAPORAN ASPIRASI',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text('Admin: $adminName'),
                  pw.SizedBox(height: 10),
                  pw.Text('Total Data: ${aspirasiList.length}'),
                  pw.SizedBox(height: 30),
                  pw.Text(
                    '📋 Data Berhasil Diexport',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // HALAMAN 2 - TABEL DATA
      if (aspirasiList.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Text('Data Aspirasi',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  // Tabel sangat sederhana
                  pw.Table(
                    children: [
                      // Header
                      pw.TableRow(
                        children: [
                          pw.Text('No',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Judul',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Status',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      // Data
                      ...aspirasiList.asMap().entries.map((entry) {
                        final a = entry.value;
                        final index = entry.key + 1;
                        return pw.TableRow(
                          children: [
                            pw.Text(index.toString()),
                            pw.Text(a.judul.length > 15
                                ? '${a.judul.substring(0, 15)}...'
                                : a.judul),
                            pw.Text(a.status),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // TUTUP LOADING
      if (context.mounted) Navigator.of(context).pop();

      // PRINT LANGSUNG
      await Printing.layoutPdf(
        onLayout: (format) => pdf.save(),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Gagal membuat PDF: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
