const PDFDocument = require('pdfkit');
const logger = require('../utils/logger');

/**
 * Generate a complete OA screening report PDF.
 * Streams directly to response object for inline preview or download.
 *
 * @param {Object} screening - Populated Screening document
 * @param {Object} patient - Populated Patient document
 * @param {Object} agent - Agent User document
 * @param {Object} res - Express response object (writable stream)
 */
const generateScreeningReport = (screening, patient, agent, res) => {
  const doc = new PDFDocument({
    size: 'A4',
    margins: { top: 60, bottom: 60, left: 60, right: 60 },
    info: {
      Title: `OA Risk Report — ${patient.fullName}`,
      Author: 'JointSaathi by MDoNER',
      Subject: 'Osteoarthritis Risk Screening Report',
    },
  });

  // Pipe to response
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader(
    'Content-Disposition',
    `inline; filename="OA_Report_${patient.fullName.replace(/\s+/g, '_')}_${
      new Date(screening.createdAt).toISOString().slice(0, 10)
    }.pdf"`
  );
  doc.pipe(res);

  const TEAL = '#0D7377';
  const DARK = '#0A0A0A';
  const GRAY = '#6B6B70';
  const BORDER = '#ECECEC';
  const PAGE_WIDTH = 595 - 120; // A4 minus margins

  // ─── HEADER BANNER ────────────────────────────────────────────────────────
  doc.rect(0, 0, 595, 90).fill(TEAL);
  doc.fillColor('#FFFFFF').fontSize(22).font('Helvetica-Bold').text('JointSaathi', 60, 25);
  doc.fontSize(10).font('Helvetica').text('AI-Assisted Osteoarthritis Risk Screening', 60, 52);
  doc.text('Ministry of Development of North Eastern Region (MDoNER)', 60, 66);

  // ─── REPORT META ───────────────────────────────────────────────────────────
  doc.fillColor(DARK).fontSize(18).font('Helvetica-Bold').text('Screening Report', 60, 110);
  doc.fontSize(9).font('Helvetica').fillColor(GRAY);
  doc.text(`Report Date: ${new Date(screening.createdAt).toLocaleDateString('en-IN', {
    day: '2-digit', month: 'long', year: 'numeric'
  })}`, { align: 'right' });
  doc.text(`Report ID: ${screening._id}`, { align: 'right' });
  doc.moveDown(0.5);

  // ─── HORIZONTAL RULE ──────────────────────────────────────────────────────
  const hrY = () => { doc.moveTo(60, doc.y).lineTo(535, doc.y).strokeColor(BORDER).stroke(); doc.moveDown(0.5); };
  hrY();

  // ─── PATIENT INFORMATION ──────────────────────────────────────────────────
  doc.fillColor(TEAL).fontSize(11).font('Helvetica-Bold').text('PATIENT INFORMATION');
  doc.moveDown(0.3);

  const col1 = 60, col2 = 310;
  const infoLine = (label, value, x, yOffset = 0) => {
    doc.fillColor(GRAY).fontSize(8).font('Helvetica').text(label, x, doc.y + yOffset);
    doc.fillColor(DARK).fontSize(10).font('Helvetica-Bold').text(value || '—', x);
    doc.moveDown(0.2);
  };

  const startY = doc.y;
  infoLine('Patient Name', patient.fullName, col1);
  infoLine('Age', `${patient.age} years`, col1);
  infoLine('Gender', patient.gender ? patient.gender.charAt(0).toUpperCase() + patient.gender.slice(1) : '—', col1);
  infoLine('Occupation', patient.occupation, col1);

  doc.y = startY;
  infoLine('Village', patient.village, col2);
  infoLine('Address', patient.address, col2);
  infoLine('Contact', patient.contact, col2);
  infoLine('Health Worker', agent.fullName, col2);

  doc.moveDown(0.5);
  hrY();

  // ─── PHYSICAL METRICS ────────────────────────────────────────────────────
  if (patient.height || patient.weight) {
    doc.fillColor(TEAL).fontSize(11).font('Helvetica-Bold').text('PHYSICAL METRICS');
    doc.moveDown(0.3);

    const bmi =
      patient.height && patient.weight
        ? (patient.weight / Math.pow(patient.height / 100, 2)).toFixed(1)
        : null;

    doc.fillColor(DARK).fontSize(10).font('Helvetica');
    if (patient.height) doc.text(`Height: ${patient.height} cm`);
    if (patient.weight) doc.text(`Weight: ${patient.weight} kg`);
    if (bmi) doc.text(`BMI: ${bmi} kg/m²`);
    doc.moveDown(0.5);
    hrY();
  }

  // ─── SYMPTOM QUESTIONNAIRE ────────────────────────────────────────────────
  doc.fillColor(TEAL).fontSize(11).font('Helvetica-Bold').text('SYMPTOM QUESTIONNAIRE');
  doc.moveDown(0.3);

  const symptomRow = (q, a) => {
    doc.fillColor(GRAY).fontSize(8).font('Helvetica').text(q);
    doc.fillColor(DARK).fontSize(10).font('Helvetica').text(a || '—');
    doc.moveDown(0.2);
  };

  symptomRow('Pain Level (0–10)', `${screening.painLevel}/10`);
  symptomRow('Morning Stiffness Duration',
    screening.stiffnessDuration === 'none' ? 'No stiffness'
    : screening.stiffnessDuration === '<30' ? 'Less than 30 minutes'
    : screening.stiffnessDuration === '30-60' ? '30–60 minutes'
    : screening.stiffnessDuration === '>60' ? 'More than 60 minutes'
    : '—'
  );
  symptomRow('Joint Swelling', screening.swelling ? 'Yes — swelling observed' : 'No swelling');
  symptomRow('History of Joint Injury', screening.pastInjury ? `Yes — ${screening.pastInjuryDetail || 'details not provided'}` : 'No prior injury');

  doc.moveDown(0.5);
  hrY();

  // ─── RISK ASSESSMENT ──────────────────────────────────────────────────────
  const riskColors = { low: '#34C759', medium: '#FF9500', high: '#FF3B30' };
  const riskColor = riskColors[screening.riskLevel] || TEAL;

  doc.fillColor(TEAL).fontSize(11).font('Helvetica-Bold').text('AI RISK ASSESSMENT');
  doc.moveDown(0.3);

  // Risk level badge
  const badgeX = 60, badgeY = doc.y;
  doc.rect(badgeX, badgeY, 120, 36).fill(riskColor);
  doc.fillColor('#FFFFFF').fontSize(14).font('Helvetica-Bold')
    .text(screening.riskLevel.toUpperCase(), badgeX, badgeY + 10, { width: 120, align: 'center' });

  doc.fillColor(GRAY).fontSize(8).font('Helvetica')
    .text(`Confidence: ${Math.round((screening.confidence || 0) * 100)}%`, badgeX + 135, badgeY + 3);
  doc.fillColor(DARK).fontSize(9)
    .text(`Source: ${screening.resultSource === 'ai_service' ? 'AI Microservice' : screening.resultSource === 'rule_based_fallback' ? 'Rule-based (AI offline)' : 'On-device (offline)'}`, badgeX + 135, badgeY + 18);

  doc.y = badgeY + 50;
  doc.moveDown(0.3);

  // Contributing factors
  if (screening.contributingFactors?.length > 0) {
    doc.fillColor(DARK).fontSize(10).font('Helvetica-Bold').text('Contributing Factors:');
    screening.contributingFactors.forEach((factor) => {
      doc.fillColor(DARK).fontSize(9).font('Helvetica').text(`  • ${factor}`);
    });
    doc.moveDown(0.3);
  }

  // Reasoning
  if (screening.reasoning) {
    doc.fillColor(DARK).fontSize(10).font('Helvetica-Bold').text('Clinical Reasoning:');
    doc.fillColor(GRAY).fontSize(9).font('Helvetica').text(screening.reasoning);
    doc.moveDown(0.3);
  }

  doc.moveDown(0.5);
  hrY();

  // ─── RECOMMENDATIONS ──────────────────────────────────────────────────────
  doc.fillColor(TEAL).fontSize(11).font('Helvetica-Bold').text('RECOMMENDATIONS');
  doc.moveDown(0.3);

  const recommendations = {
    high: [
      'Refer urgently to an orthopedic specialist for clinical evaluation',
      'Consider X-ray or MRI imaging of affected joints',
      'Prescribe analgesics as per clinical guidelines pending specialist review',
      'Educate patient on joint protection techniques',
      'Schedule follow-up within 2 weeks',
    ],
    medium: [
      'Schedule consultation with a physician or specialist within 1 month',
      'Recommend physiotherapy assessment',
      'Encourage weight management if BMI > 25 kg/m²',
      'Prescribe low-impact exercise program (walking, swimming)',
      'Schedule follow-up screening in 3 months',
    ],
    low: [
      'Encourage maintenance of healthy lifestyle and weight',
      'Recommend regular weight-bearing exercise (30 min/day)',
      'Advise balanced diet rich in calcium and vitamin D',
      'Schedule routine screening in 6–12 months',
      'Educate on early OA symptoms to watch for',
    ],
  };

  (recommendations[screening.riskLevel] || recommendations.low).forEach((rec, i) => {
    doc.fillColor(DARK).fontSize(9).font('Helvetica').text(`${i + 1}. ${rec}`);
    doc.moveDown(0.15);
  });

  doc.moveDown(0.5);
  hrY();

  // ─── FOOTER ───────────────────────────────────────────────────────────────
  doc.fillColor(GRAY).fontSize(7).text(
    'This report is generated by JointSaathi AI screening tool and is intended to assist — not replace — clinical judgment. ' +
    'All findings must be interpreted by a qualified healthcare professional. ' +
    'For MDoNER Smart India Hackathon demonstration purposes.',
    60, 770, { width: PAGE_WIDTH, align: 'center' }
  );

  doc.end();
  logger.info(`PDF generated for patient: ${patient.fullName}, screening: ${screening._id}`);
};

module.exports = { generateScreeningReport };
