import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../app/theme.dart';

class ReportPreviewDialog extends StatelessWidget {
  final pw.Document pdf;

  const ReportPreviewDialog({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Preview Laporan PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // PREVIEW
            Expanded(
              child: PdfPreview(
                build: (format) => pdf.save(),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
              ),
            ),

            // ACTION BUTTONS
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Tutup'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Printing.sharePdf(
                        bytes: await pdf.save(),
                        filename:
                            'laporan_aspirasi_${DateTime.now().millisecondsSinceEpoch}.pdf',
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Printing.layoutPdf(
                        onLayout: (format) => pdf.save(),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Cetak'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
