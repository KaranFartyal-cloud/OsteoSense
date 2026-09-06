const mongoose = require('mongoose');

const preventiveCareSchema = new mongoose.Schema(
  {
    category: {
      type: String,
      enum: ['exercises', 'diet', 'lifestyle'],
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    summary: {
      type: String,
      required: true,
      trim: true,
    },
    content: {
      type: String,
      required: true,
    },
    imageUrl: {
      type: String,
    },
    tags: {
      type: [String],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    order: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Seed default content if collection is empty
preventiveCareSchema.statics.seedDefaults = async function () {
  const count = await this.countDocuments();
  if (count > 0) return;

  const defaults = [
    // EXERCISES
    {
      category: 'exercises',
      title: 'Quadriceps Strengthening',
      summary: 'Simple exercises to strengthen the muscles around your knee',
      content: `Strong quadriceps muscles help support and protect the knee joint, reducing stress on cartilage.\n\n**Straight Leg Raises (3 sets of 15 reps)**\n1. Lie flat on your back\n2. Keep one leg bent at 90° with foot flat on floor\n3. Slowly raise the straight leg to the height of the bent knee\n4. Hold for 3 seconds, lower slowly\n\n**Wall Squats (3 sets of 10 reps)**\n1. Stand with back against wall, feet shoulder-width apart\n2. Slide down until knees are at 45–60° angle\n3. Hold for 10 seconds, slide back up\n\nDo these daily. Avoid pain — if any exercise causes sharp pain, stop immediately.`,
      tags: ['knee', 'strength', 'beginner'],
      order: 1,
    },
    {
      category: 'exercises',
      title: 'Low-Impact Aerobics',
      summary: 'Walking and water exercises safe for arthritic joints',
      content: `Aerobic exercise improves cardiovascular health and helps maintain healthy weight, reducing joint load.\n\n**Daily Walking**\n- Start with 10 minutes, increase by 5 min per week up to 30 minutes\n- Wear cushioned, supportive footwear\n- Walk on flat, even surfaces\n- Use a walking stick if needed for balance\n\n**Swimming / Water Aerobics**\n- Water buoyancy reduces joint impact by 75%\n- Aim for 30 minutes, 3 times per week\n- Freestyle and backstroke are gentlest on joints\n\n**Cycling (Stationary)**\n- Set seat height so knee bends only slightly at bottom of pedal stroke\n- Low resistance, medium cadence\n- 20–30 minutes, 3–5 times per week`,
      tags: ['aerobic', 'walking', 'low-impact'],
      order: 2,
    },
    {
      category: 'exercises',
      title: 'Range of Motion Exercises',
      summary: 'Stretches to maintain joint flexibility and reduce stiffness',
      content: `Range of motion exercises help maintain joint flexibility, reduce morning stiffness, and keep cartilage nourished.\n\n**Best done in the morning after applying gentle warmth to joints.**\n\n**Ankle Circles** — 10 circles each direction, each ankle\n\n**Knee Flexion/Extension**\n- Sit on chair, slowly straighten knee as far as comfortable\n- Hold 5 seconds, lower slowly\n- 10 reps each leg\n\n**Hip Circles**\n- Stand holding support\n- Gently swing leg forward, to side, backward in controlled arc\n- 10 reps each leg`,
      tags: ['flexibility', 'stretching', 'stiffness'],
      order: 3,
    },

    // DIET
    {
      category: 'diet',
      title: 'Anti-Inflammatory Foods',
      summary: 'Foods that help reduce joint inflammation and pain',
      content: `Inflammation plays a major role in OA progression. Including anti-inflammatory foods can help manage symptoms.\n\n**Include more of:**\n- 🐟 **Fatty fish** (salmon, mackerel, sardines) — rich in omega-3 fatty acids, 2–3 servings/week\n- 🫒 **Mustard oil / olive oil** — contains oleocanthal, which acts like ibuprofen\n- 🧅 **Turmeric + black pepper** — curcumin is a potent anti-inflammatory\n- 🫐 **Berries, amla, citrus** — vitamin C for collagen synthesis\n- 🥬 **Leafy greens** — spinach, fenugreek, methi leaves\n- 🧄 **Ginger and garlic** — natural anti-inflammatory compounds\n\n**Limit:**\n- Refined sugars and processed foods\n- Excessive red meat\n- Deep-fried foods`,
      tags: ['anti-inflammatory', 'omega-3', 'turmeric'],
      order: 1,
    },
    {
      category: 'diet',
      title: 'Calcium & Vitamin D',
      summary: 'Essential nutrients for bone and joint health',
      content: `Adequate calcium and vitamin D are critical for maintaining bone density and joint health, especially in OA.\n\n**Calcium Sources (aim for 1000–1200 mg/day):**\n- 🥛 Milk, curd, paneer, buttermilk\n- 🌿 Ragi (finger millet) — exceptional calcium source\n- 🥬 Drumstick leaves, amaranth leaves\n- 🫘 Bengal gram, rajma, black-eyed peas\n- 🐟 Small fish eaten with bones\n\n**Vitamin D (aim for 600–800 IU/day):**\n- ☀️ Sun exposure: 15–20 minutes between 10 AM–2 PM, 3–4 times/week\n- Egg yolk, fatty fish, mushrooms (sun-exposed)\n- Fortified milk and cereals\n\n**Note:** Vitamin D enhances calcium absorption — both are needed together.`,
      tags: ['calcium', 'vitamin-d', 'bone-health'],
      order: 2,
    },
    {
      category: 'diet',
      title: 'Weight Management Diet',
      summary: 'Every kilogram lost reduces knee joint load by 4 kg',
      content: `Excess body weight dramatically increases mechanical stress on weight-bearing joints. Even modest weight loss significantly reduces OA symptoms.\n\n**Key Principles:**\n\n**Portion Control**\n- Use smaller plates\n- Eat slowly — it takes 20 minutes for satiety signals to reach the brain\n- Fill half the plate with vegetables\n\n**Reduce Calorie-Dense Foods**\n- Limit sweets, namkeens, and deep-fried snacks\n- Replace white rice/bread with millets, jowar, bajra\n- Avoid sugary drinks — replace with water, lassi, chaas\n\n**Increase Protein**\n- Protein helps maintain muscle mass which supports joints\n- Include dal, eggs, paneer, or fish at every meal\n\n**Goal:** Lose 5–10% of body weight if overweight. Even this much reduces knee pain by 20–30%.`,
      tags: ['weight-loss', 'diet', 'knee-health'],
      order: 3,
    },

    // LIFESTYLE
    {
      category: 'lifestyle',
      title: 'Joint Protection Techniques',
      summary: 'Daily habits to protect joints and prevent further damage',
      content: `Simple modifications in daily activities can significantly reduce joint stress and prevent OA progression.\n\n**Sitting & Standing**\n- Use chairs with armrests — push up using arms when rising\n- Avoid sitting on the floor for extended periods\n- Use a raised toilet seat if rising from low position is painful\n- Take a 5-minute movement break every 45 minutes of sitting\n\n**Carrying & Lifting**\n- Carry bags with shoulder strap, not hands (reduces finger/wrist joint load)\n- Distribute weight — carry lighter loads in both hands\n- Use wheeled bags/trolleys when possible\n\n**Footwear**\n- Always wear supportive, cushioned footwear — even at home\n- Avoid flat chappals — they provide no arch support\n- Consider knee-unloading insoles for medial compartment OA\n\n**Sleeping Position**\n- Sleep with a pillow between knees to maintain hip alignment\n- Avoid sleeping on stomach (strains the spine)`,
      tags: ['joint-protection', 'daily-habits', 'ergonomics'],
      order: 1,
    },
    {
      category: 'lifestyle',
      title: 'Stress Management',
      summary: 'How stress affects joint pain and how to manage it',
      content: `Psychological stress worsens pain perception and inflammation, creating a vicious cycle in OA. Managing stress is an important part of OA care.\n\n**Mindfulness & Breathing**\n- 5 minutes of slow diaphragmatic breathing twice daily\n- Box breathing: inhale 4 counts, hold 4, exhale 4, hold 4\n\n**Yoga (Joint-Safe)**\n- Yoga Nidra (body scan meditation) — no physical movement required\n- Seated pranayama (breathing exercises)\n- Gentle supine yoga poses\n- Avoid deep squats, padmasana if knee pain is present\n\n**Social Connection**\n- Isolation worsens pain — stay socially active\n- Join a health group or walking group in your village\n- Speak to an ASHA or ANM worker regularly\n\n**Sleep Hygiene**\n- 7–8 hours of sleep is essential for tissue repair\n- Maintain consistent sleep/wake times\n- Avoid screens 1 hour before sleep`,
      tags: ['stress', 'mental-health', 'yoga', 'sleep'],
      order: 2,
    },
    {
      category: 'lifestyle',
      title: 'Heat & Cold Therapy',
      summary: 'When to use heat vs cold for joint pain relief',
      content: `Thermotherapy (heat) and cryotherapy (cold) are simple, effective, low-cost interventions for OA pain management.\n\n**Heat Therapy — for chronic stiffness & muscle spasm**\n- Best for: morning stiffness, chronic dull ache, muscle tension\n- Method: warm towel, hot water bottle, or warm bath\n- Apply for 15–20 minutes\n- Ensure temperature is warm, not hot — risk of burns is high in patients with reduced sensation\n- Do NOT use on acutely swollen/inflamed joints\n\n**Cold Therapy — for acute swelling & inflammation**\n- Best for: after exercise, acute flare-up, warm swollen joint\n- Method: ice pack wrapped in cloth (never apply ice directly to skin)\n- Apply for 10–15 minutes\n- Rest 45 minutes before re-applying\n\n**Contrast Therapy**\n- Alternate heat (3 min) and cold (1 min) for 20 minutes\n- Helps with chronic pain and stiffness\n\n**Safety:** Never apply directly to skin. Check skin frequently. Stop if pain increases.`,
      tags: ['heat', 'cold', 'pain-relief', 'home-remedy'],
      order: 3,
    },
  ];

  await this.insertMany(defaults);
};

module.exports = mongoose.model('PreventiveCare', preventiveCareSchema);
