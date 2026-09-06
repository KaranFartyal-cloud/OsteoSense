'use strict';

/**
 * Standalone seed script for the PreventiveCare collection.
 * Run via: npm run seed
 *
 * Populates ~12 realistic entries across exercises/diet/lifestyle
 * categories, in English and Hindi, covering the core OA preventive-care
 * topics (knee strengthening, anti-inflammatory diet, weight management, etc.)
 */

const mongoose = require('mongoose');
const connectDB = require('./config/db');
const PreventiveCare = require('./models/PreventiveCare');
const logger = require('./utils/logger');

const seedData = [
  // ---- Exercises (English) ----
  {
    category: 'exercises',
    language: 'en',
    title: 'Straight Leg Raises for Knee Strength',
    content:
      'Lie flat on your back with one leg bent and the other straight. Slowly lift the ' +
      'straight leg to the height of the bent knee, hold for 5 seconds, then lower. ' +
      'Repeat 10 times per leg, twice a day. Strengthens the quadriceps without stressing the knee joint.',
  },
  {
    category: 'exercises',
    language: 'en',
    title: 'Gentle Chair Squats',
    content:
      'Stand in front of a sturdy chair with feet shoulder-width apart. Slowly lower yourself ' +
      'as if sitting down, tap the chair lightly, then rise back up. Perform 8-10 repetitions. ' +
      'Builds thigh and hip strength that supports the knee joint.',
  },
  {
    category: 'exercises',
    language: 'en',
    title: 'Daily Low-Impact Walking',
    content:
      'A 20-30 minute walk on flat ground each day helps lubricate joints and maintain ' +
      'mobility. Wear supportive footwear and avoid uneven or rocky terrain to reduce joint strain.',
  },
  {
    category: 'exercises',
    language: 'en',
    title: 'Water-Based Exercises',
    content:
      'If a pond or shallow water body is accessible, gentle water walking or leg movements ' +
      'reduce the load on joints while still building strength, thanks to water buoyancy.',
  },
  // ---- Exercises (Hindi) ----
  {
    category: 'exercises',
    language: 'hi',
    title: 'घुटने की मजबूती के लिए सीधा पैर उठाना',
    content:
      'पीठ के बल सीधे लेट जाएं, एक पैर मोड़ें और दूसरा सीधा रखें। सीधे पैर को धीरे-धीरे मुड़े हुए ' +
      'घुटने की ऊंचाई तक उठाएं, 5 सेकंड रोकें, फिर नीचे लाएं। हर पैर से 10 बार, दिन में दो बार दोहराएं।',
  },
  {
    category: 'exercises',
    language: 'hi',
    title: 'हल्की कुर्सी बैठक (चेयर स्क्वाट)',
    content:
      'एक मजबूत कुर्सी के सामने कंधों जितनी दूरी पर पैर रखकर खड़े हों। धीरे-धीरे बैठने जैसा करें, ' +
      'कुर्सी को हल्के से छुएं, फिर वापस उठें। 8-10 बार दोहराएं। जांघ और कूल्हे को मजबूत बनाता है।',
  },
  {
    category: 'exercises',
    language: 'hi',
    title: 'रोज़ाना हल्की सैर',
    content:
      'रोज़ 20-30 मिनट समतल जमीन पर चलना जोड़ों को चिकनाई देने और गतिशीलता बनाए रखने में मदद करता है। ' +
      'आरामदायक जूते पहनें और असमान या पथरीले रास्ते से बचें।',
  },
  // ---- Diet (English) ----
  {
    category: 'diet',
    language: 'en',
    title: 'Anti-Inflammatory Foods',
    content:
      'Include turmeric, ginger, leafy greens, and fatty fish (like local river fish) in your ' +
      'diet. These contain natural anti-inflammatory compounds that may help reduce joint pain and swelling.',
  },
  {
    category: 'diet',
    language: 'en',
    title: 'Calcium and Vitamin D Rich Foods',
    content:
      'Consume milk, curd, sesame seeds, and eggs regularly. Combine with 15-20 minutes of ' +
      'morning sunlight exposure to help the body absorb calcium, supporting bone and joint health.',
  },
  {
    category: 'diet',
    language: 'en',
    title: 'Limit Processed and Sugary Foods',
    content:
      'Reduce intake of fried snacks, sugary beverages, and processed packaged foods, which ' +
      'can contribute to inflammation and unwanted weight gain that adds stress on joints.',
  },
  // ---- Diet (Hindi) ----
  {
    category: 'diet',
    language: 'hi',
    title: 'सूजन कम करने वाले खाद्य पदार्थ',
    content:
      'अपने भोजन में हल्दी, अदरक, हरी पत्तेदार सब्जियां और स्थानीय नदी की मछली शामिल करें। ये ' +
      'प्राकृतिक रूप से सूजन कम करने में मदद कर सकते हैं और जोड़ों के दर्द को घटा सकते हैं।',
  },
  {
    category: 'diet',
    language: 'hi',
    title: 'कैल्शियम और विटामिन डी युक्त आहार',
    content:
      'नियमित रूप से दूध, दही, तिल के बीज और अंडे खाएं। सुबह 15-20 मिनट धूप में रहने से शरीर ' +
      'कैल्शियम बेहतर तरीके से अवशोषित करता है, जिससे हड्डियां और जोड़ मजबूत रहते हैं।',
  },
  // ---- Lifestyle (English) ----
  {
    category: 'lifestyle',
    language: 'en',
    title: 'Maintain a Healthy Body Weight',
    content:
      'Every extra kilogram of body weight adds significant pressure on knee joints while ' +
      'walking. Gradual, sustainable weight management through diet and gentle exercise ' +
      'can meaningfully reduce OA risk and symptom severity.',
  },
  {
    category: 'lifestyle',
    language: 'en',
    title: 'Avoid Prolonged Squatting or Floor-Sitting',
    content:
      'Traditional floor-sitting and deep squatting (common in daily chores) place high ' +
      'stress on knee joints. Where possible, use a low stool or chair for tasks like cooking ' +
      'or washing to reduce repetitive joint strain.',
  },
  // ---- Lifestyle (Hindi) ----
  {
    category: 'lifestyle',
    language: 'hi',
    title: 'स्वस्थ शरीर का वजन बनाए रखें',
    content:
      'शरीर का हर अतिरिक्त किलोग्राम वजन चलते समय घुटनों के जोड़ों पर दबाव बढ़ाता है। आहार और ' +
      'हल्के व्यायाम से धीरे-धीरे वजन नियंत्रित करने से जोड़ों की समस्या का खतरा कम हो सकता है।',
  },
  {
    category: 'lifestyle',
    language: 'hi',
    title: 'लंबे समय तक बैठकर काम करने से बचें',
    content:
      'पारंपरिक रूप से जमीन पर बैठकर या गहरी मुद्रा में काम करने से घुटनों पर अधिक दबाव पड़ता है। ' +
      'जहां संभव हो, खाना पकाने या कपड़े धोने जैसे कामों के लिए नीचे स्टूल या कुर्सी का उपयोग करें।',
  },
];

async function seed() {
  try {
    await connectDB();
    logger.info('Seeding PreventiveCare collection...');

    await PreventiveCare.deleteMany({});
    const inserted = await PreventiveCare.insertMany(seedData);

    logger.info(`Seeded ${inserted.length} PreventiveCare entries successfully.`);
  } catch (err) {
    logger.error('Seeding failed', { error: err.message });
    process.exitCode = 1;
  } finally {
    await mongoose.connection.close();
  }
}

seed();
