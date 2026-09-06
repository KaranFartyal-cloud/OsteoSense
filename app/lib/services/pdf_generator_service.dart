import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/screening.dart';

/// Lightweight static wrapper used by [PdfPreviewScreen].
/// Returns raw Uint8List bytes so the [printing] package's PdfPreview widget
/// can render inline and the share/download actions can send the file.
class PdfService {
  PdfService._();

  static Future<Uint8List> generateScreeningReport({
    required Screening screening,
    required Patient patient,
    String? agentName,
  }) async {
    final pdf = pw.Document();

    const teal = PdfColor.fromInt(0xFF0D7377);
    const darkText = PdfColor.fromInt(0xFF0A0A0A);
    const grayText = PdfColor.fromInt(0xFF6B6B70);
    const borderColor = PdfColor.fromInt(0xFFECECEC);

    final riskColor = _riskPdfColor(screening.riskLevel ?? 'low');
    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(screening.screeningDate);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 60),
        build: (context) => [
          // ── Header banner
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            color: teal,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('JointSaathi',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('AI-Assisted Osteoarthritis Risk Screening',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                  ],
                ),
                pw.Text('MDoNER / Smart India Hackathon',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 8)),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Report title + date
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Screening Report',
                  style: const pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: darkText)),
              pw.Text(dateStr, style: const pw.TextStyle(fontSize: 9, color: grayText)),
            ],
          ),
          pw.Divider(color: borderColor, thickness: 1),
          pw.SizedBox(height: 12),

          // ── Patient info
          _section('Patient Information', teal),
          pw.SizedBox(height: 8),
          _infoGrid([
            ['Name', patient.name],
            ['Age', '${patient.age} years'],
            ['Gender', _capitalize(patient.gender)],
            ['Village', patient.village ?? '—'],
            ['Contact', patient.contact ?? '—'],
            ['Occupation', patient.occupation ?? '—'],
            if (agentName != null) ['Health Worker', agentName],
          ]),

          pw.SizedBox(height: 16),

          // ── Risk result
          _section('Risk Assessment', teal),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: riskColor.shade(0.15),
              border: pw.Border.all(color: riskColor, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: riskColor,
                  child: pw.Text(
                    (screening.riskLevel ?? 'low').toUpperCase(),
                    style: const pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 14),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Confidence: ${((screening.confidence ?? 0) * 100).round()}%',
                        style: const pw.TextStyle(fontSize: 10, color: grayText)),
                    pw.Text(
                      'Source: ${_sourceLabel(screening)}',
                      style: const pw.TextStyle(fontSize: 9, color: grayText),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // ── Symptoms
          _section('Symptom Questionnaire', teal),
          pw.SizedBox(height: 8),
          _infoGrid([
            ['Pain Level', '${screening.painLevel ?? 0} / 10'],
            ['Morning Stiffness', _stiffnessLabel(screening.stiffnessDuration)],
            ['Joint Swelling', screening.swelling == true ? 'Yes' : 'No'],
            ['Past Injury', (screening.pastInjury ?? '').isNotEmpty ? 'Yes — ${screening.pastInjury}' : 'No'],
          ]),

          pw.SizedBox(height: 16),

          // ── Contributing factors
          _section('Contributing Factors', teal),
          pw.SizedBox(height: 8),
          ..._factorsList(screening),

          pw.SizedBox(height: 16),

          // ── AI Reasoning
          if (screening.aiReasoning != null) ...[
            _section('Clinical Reasoning', teal),
            pw.SizedBox(height: 8),
            pw.Text(screening.aiReasoning!, style: const pw.TextStyle(fontSize: 10, color: grayText)),
            pw.SizedBox(height: 16),
          ],

          // ── Recommendations
          _section('Recommendations', teal),
          pw.SizedBox(height: 8),
          ..._getRecommendations(screening.riskLevel ?? 'low').asMap().entries.map(
                (e) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('${e.key + 1}. ${e.value}',
                      style: const pw.TextStyle(fontSize: 10, color: darkText)),
                ),
              ),

          pw.SizedBox(height: 24),

          // ── Footer
          pw.Divider(color: borderColor),
          pw.Text(
            'This report is generated by JointSaathi AI screening tool and is intended to assist — not replace — clinical judgment. '
            'All findings must be interpreted by a qualified healthcare professional.',
            style: const pw.TextStyle(fontSize: 7, color: grayText),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _section(String title, PdfColor color) {
    return pw.Text(title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color));
  }

  static pw.Widget _infoGrid(List<List<String>> rows) {
    return pw.Table(
      columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(2)},
      children: rows.map((row) {
        return pw.TableRow(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(row[0], style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF6B6B70))),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(row[1],
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF0A0A0A))),
          ),
        ]);
      }).toList(),
    );
  }

  static List<pw.Widget> _factorsList(Screening screening) {
    final factors = (screening.contributingFactors ?? '')
        .split('|')
        .where((f) => f.trim().isNotEmpty)
        .toList();
    if (factors.isEmpty) {
      return [
        pw.Text('No significant risk factors detected.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF34C759))),
      ];
    }
    return factors.map((f) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text('• ${f.trim()}', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF0A0A0A))),
      );
    }).toList();
  }

  static PdfColor _riskPdfColor(String riskLevel) {
    switch (riskLevel) {
      case 'high': return const PdfColor.fromInt(0xFFFF3B30);
      case 'medium': return const PdfColor.fromInt(0xFFFF9500);
      default: return const PdfColor.fromInt(0xFF34C759);
    }
  }

  static String _stiffnessLabel(String? val) {
    switch (val) {
      case '<30': return 'Less than 30 minutes';
      case '30-60': return '30–60 minutes';
      case '>60': return 'More than 60 minutes';
      default: return 'No stiffness';
    }
  }

  static String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _sourceLabel(Screening screening) => 'AI Assessment';

  static List<String> _getRecommendations(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return [
          'Refer urgently to an orthopedic specialist for clinical evaluation',
          'Consider X-ray or MRI imaging of affected joints',
          'Prescribe analgesics as per clinical guidelines',
          'Educate patient on joint protection techniques',
          'Schedule follow-up within 2 weeks',
        ];
      case 'medium':
        return [
          'Schedule consultation with a physician within 1 month',
          'Recommend physiotherapy assessment',
          'Encourage weight management if BMI > 25 kg/m²',
          'Prescribe low-impact exercise program',
          'Follow-up screening in 3 months',
        ];
      default:
        return [
          'Maintain healthy lifestyle and regular exercise (30 min/day)',
          'Ensure adequate calcium and vitamin D intake',
          'Schedule routine screening in 6–12 months',
          'Educate patient on early OA symptoms to watch for',
        ];
    }
  }
}
