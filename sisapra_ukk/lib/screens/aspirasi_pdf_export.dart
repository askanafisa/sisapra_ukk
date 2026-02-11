import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../app/data.dart';

/// Screen untuk generate dan preview PDF laporan aspirasi
class AspirasiPdfExportScreen extends StatefulWidget {
  final List<Aspirasi> aspirasi;
  final String? filterTitle;

  const AspirasiPdfExportScreen({
    super.key,
    required this.aspirasi,
    this.filterTitle,
  });

  @override
  State<AspirasiPdfExportScreen> createState() =>
      _AspirasiPdfExportScreenState();
}

class _AspirasiPdfExportScreenState extends State<AspirasiPdfExportScreen> {
  late Future<pw.Document> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _generatePdf();
  }

  Future<pw.Document> _generatePdf() async {
    final doc = pw.Document();

    // Group aspirasi by status untuk summary
    final Map<String, int> statusCount = {};
    final Map<String, int> categoryCount = {};

    for (var a in widget.aspirasi) {
      statusCount[a.status] = (statusCount[a.status] ?? 0) + 1;
      categoryCount[a.kategori] = (categoryCount[a.kategori] ?? 0) + 1;
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 2)),
          ),
          padding: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SISAPRA - Sistem Informasi Sarana Prasarana',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Laporan Data Aspirasi Siswa',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Text(
                formatDate(DateTime.now()),
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(width: 1)),
          ),
          padding: const pw.EdgeInsets.only(top: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '© 2026 SISAPRA - Sekolah',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
        build: (context) => [
          // HEADER
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'LAPORAN ASPIRASI SISWA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  widget.filterTitle ?? 'Semua Data',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          ),

          // SUMMARY STATISTICS
          pw.Text(
            '📊 RINGKASAN DATA',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          // Stats Row 1
          pw.Row(
            children: [
              _buildStatBox(
                'Total Aspirasi',
                '${widget.aspirasi.length}',
                '0066FF',
              ),
              pw.SizedBox(width: 15),
              _buildStatBox(
                'Menunggu',
                '${statusCount['pending'] ?? 0}',
                'FFA500',
              ),
              pw.SizedBox(width: 15),
              _buildStatBox(
                'Diproses',
                '${statusCount['proses'] ?? 0}',
                '3B82F6',
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Stats Row 2
          pw.Row(
            children: [
              _buildStatBox(
                'Selesai',
                '${statusCount['selesai'] ?? 0}',
                '10B981',
              ),
              pw.SizedBox(width: 15),
              _buildStatBox(
                'Ditolak',
                '${statusCount['ditolak'] ?? 0}',
                'EF4444',
              ),
              pw.SizedBox(width: 15),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ),

          pw.SizedBox(height: 20),

          // KATEGORI BREAKDOWN
          pw.Text(
            '🏷️ BREAKDOWN PER KATEGORI',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(width: 1),
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Kategori',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Jumlah',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Data rows
              ...categoryCount.entries.map((e) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(e.key),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('${e.value}'),
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // DETAIL ASPIRASI TABLE
          pw.Text(
            '📝 DETAIL ASPIRASI',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5), // No
              1: const pw.FlexColumnWidth(2), // Nama
              2: const pw.FlexColumnWidth(2.5), // Judul
              3: const pw.FlexColumnWidth(1.2), // Kategori
              4: const pw.FlexColumnWidth(1), // Status
              5: const pw.FlexColumnWidth(1.5), // Tanggal
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _buildTableHeader('No'),
                  _buildTableHeader('Nama Siswa'),
                  _buildTableHeader('Judul Aspirasi'),
                  _buildTableHeader('Kategori'),
                  _buildTableHeader('Status'),
                  _buildTableHeader('Tanggal'),
                ],
              ),
              // Data rows
              ...List.generate(
                widget.aspirasi.length,
                (idx) {
                  final a = widget.aspirasi[idx];
                  return pw.TableRow(
                    children: [
                      _buildTableCell('${idx + 1}', fontSize: 10),
                      _buildTableCell(a.nama, fontSize: 9),
                      _buildTableCell(a.judul, fontSize: 9),
                      _buildTableCell(a.kategori, fontSize: 9),
                      _buildTableCell(_getStatusLabel(a.status), fontSize: 9),
                      _buildTableCell(formatDate(a.tanggal), fontSize: 9),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    return doc;
  }

  pw.Widget _buildStatBox(String label, String value, String colorHex) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: PdfColor.fromHex(colorHex),
            width: 2,
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex(colorHex),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {double fontSize = 9}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: fontSize),
        maxLines: 2,
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return '⏳ Menunggu';
      case 'proses':
        return '🔄 Diproses';
      case 'selesai':
        return '✅ Selesai';
      case 'ditolak':
        return '❌ Ditolak';
      default:
        return status;
    }
  }

  String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 Preview PDF Laporan'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final pdf = await _pdfFuture;
              await Printing.sharePdf(
                bytes: await pdf.save(),
                filename:
                    'Laporan_Aspirasi_${DateTime.now().toString().split(' ')[0]}.pdf',
              );
            },
            tooltip: 'Download/Share PDF',
          ),
        ],
      ),
      body: FutureBuilder<pw.Document>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('Gagal generate PDF'),
            );
          }

          return PdfPreview(
            onPrinted: (_) => Navigator.pop(context),
            onShared: (_) => Navigator.pop(context),
            build: (format) => snapshot.data!.save(),
          );
        },
      ),
    );
  }
}
