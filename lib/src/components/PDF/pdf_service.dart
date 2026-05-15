import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/user.dart';
import '../../utils/amina_term_text.dart';


class PdfService {
  static Future<File> generatePdfWithSignature({
    required Uint8List signatureBytes,
    required User user,
  }) async {
    final pdf = pw.Document();
    final signatureImage = pw.MemoryImage(signatureBytes);
    final currentDate = DateTime.now().toLocal().toString().split(' ')[0];

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.symmetric(horizontal: 35, vertical: 40),
        build: (context) => [
          _buildTitle(),
          pw.SizedBox(height: 24),
          _buildUserSection(user),
          pw.SizedBox(height: 24),
          ..._buildTermsSection(),
          pw.SizedBox(height: 30),
          _buildSignatureSection(signatureImage, currentDate),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/contrato_usuario.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildTitle() {
    return pw.Center(
      child: pw.Text(
        'Contrato de Registro de Usuario',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildUserSection(User user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Datos del Usuario',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Divider(),
        pw.Text('Nombre Completo: ${user.name} ${user.lastname}'),
        pw.Text('Correo Electrónico: ${user.email}'),
        pw.Text('Cédula: ${user.ci}'),
        pw.Text('Teléfono: ${user.phone}'),
      ],
    );
  }

  static List<pw.Widget> _buildTermsSection() {
    final paragraphs = aminaTermsAndConditions
        .split('\n\n')
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .toList();

    return [
      pw.Text(
        'Términos y Condiciones',
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.Divider(),
      ...paragraphs.map(
            (paragraph) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            paragraph.trim(),
            style: const pw.TextStyle(fontSize: 12),
            textAlign: pw.TextAlign.justify,
          ),
        ),
      ),
    ];
  }

  static pw.Widget _buildSignatureSection(
      pw.MemoryImage signatureImage,
      String currentDate,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Firma del Usuario',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Image(signatureImage, width: 180, height: 90),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Fecha: $currentDate'),
      ],
    );
  }
}