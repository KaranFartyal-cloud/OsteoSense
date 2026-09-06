import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/patient.dart';
import '../models/screening.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PDFService {
  static PDFService? _instance;

  factory PDFService() {
    _instance ??= PDFService._internal();
    return _instance!;
  }

  PDFService._internal();

  Future<void> generateScreeningReport(
    Patient patient,
    Screening screening,
    String workerName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(patient, screening),
            pw.SizedBox(height: 24),
            _buildPatientInfo(patient),
            pw.SizedBox(height: 24),
            _buildScreeningResults(screening),
            pw.SizedBox(height: 24),
            _buildContributingFactors(screening),
            pw.SizedBox(height: 24),
            _buildRecommendations(screening),
            pw.SizedBox(height: 24),
            _buildFooter(workerName),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildHeader(Patient patient, Screening screening) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'JointSaathi',
              style: const pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal,
              ),
            ),
            pw.Text(
              'Osteoarthritis Risk Screening Report',
              style: const pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.normal,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.teal),
        pw.SizedBox(height: 8),
        pw.Text(
          'Report Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: const pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Name', patient.name),
          _buildInfoRow('Age', '${patient.age} years'),
          _buildInfoRow('Gender', patient.gender),
          if (patient.contact != null) _buildInfoRow('Contact', patient.contact!),
          if (patient.village != null) _buildInfoRow('Village', patient.village!),
          if (patient.address != null) _buildInfoRow('Address', patient.address!),
          if (patient.occupation != null) _buildInfoRow('Occupation', patient.occupation!),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(color: PdfColors.grey900),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildScreeningResults(Screening screening) {
    final riskColor = _getRiskColor(screening.riskLevel ?? 'low');
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: riskColor, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Screening Results',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: riskColor,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Risk Level:',
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: riskColor,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  (screening.riskLevel ?? 'low').toUpperCase(),
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Confidence:',
                style: const pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${((screening.confidence ?? 0.0) * 100).toStringAsFixed(1)}%',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Screening Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(screening.screeningDate)}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildContributingFactors(Screening screening) {
    final factors = screening.contributingFactors?.split(',') ?? [];
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Contributing Factors',
            style: const pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal,
            ),
          ),
          pw.SizedBox(height: 12),
          if (factors.isEmpty)
            pw.Text('No specific factors identified', style: const pw.TextStyle(color: PdfColors.grey600))
          else
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: factors.map((factor) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: const pw.TextStyle(color: PdfColors.teal)),
                      pw.Expanded(
                        child: pw.Text(
                          factor.trim(),
                          style: const pw.TextStyle(color: PdfColors.grey800),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildRecommendations(Screening screening) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Doctor Recommendations',
            style: const pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            screening.doctorRecommendations ?? 'No specific recommendations provided.',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(String workerName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Text(
          'Screening conducted by: $workerName',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'This report is generated by JointSaathi - AI-assisted early detection for Osteoarthritis risk screening.',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'For medical emergencies, please consult a healthcare professional immediately.',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.red700),
        ),
      ],
    );
  }

  PdfColor _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return PdfColors.red;
      case 'medium':
        return PdfColors.orange;
      case 'low':
      default:
        return PdfColors.green;
    }
  }

  Future<String> savePDF(Patient patient, Screening screening) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(patient, screening),
            pw.SizedBox(height: 24),
            _buildPatientInfo(patient),
            pw.SizedBox(height: 24),
            _buildScreeningResults(screening),
            pw.SizedBox(height: 24),
            _buildContributingFactors(screening),
            pw.SizedBox(height: 24),
            _buildRecommendations(screening),
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'screening_${patient.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    return file.path;
  }

  Future<void> sharePDF(String filePath) async {
    await Printing.sharePdf(bytes: await File(filePath).readAsBytes(), filename: filePath.split('/').last);
  }
}
