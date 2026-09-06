import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import 'preventive_care_article_screen.dart';

// ─── Local article data (until API integration) ──────────────────────────────
const _exercisesArticles = [
  _Article(
    id: 'ex1',
    title: 'Quadriceps Strengthening',
    summary: 'Simple exercises to strengthen the muscles around your knee',
    icon: Icons.fitness_center_rounded,
    readTime: '4 min',
    content: '''Strong quadriceps muscles help support and protect the knee joint, reducing stress on cartilage.

**Straight Leg Raises (3 sets of 15 reps)**
1. Lie flat on your back
2. Keep one leg bent at 90° with foot flat on floor
3. Slowly raise the straight leg to the height of the bent knee
4. Hold for 3 seconds, lower slowly

**Wall Squats (3 sets of 10 reps)**
1. Stand with back against wall, feet shoulder-width apart
2. Slide down until knees are at 45–60° angle
3. Hold for 10 seconds, slide back up

Do these daily. Avoid pain — if any exercise causes sharp pain, stop immediately.''',
  ),
  _Article(
    id: 'ex2',
    title: 'Low-Impact Aerobics',
    summary: 'Walking and water exercises safe for arthritic joints',
    icon: Icons.directions_walk_rounded,
    readTime: '3 min',
    content: '''Aerobic exercise improves cardiovascular health and helps maintain healthy weight, reducing joint load.

**Daily Walking**
- Start with 10 minutes, increase by 5 min per week up to 30 minutes
- Wear cushioned, supportive footwear
- Walk on flat, even surfaces

**Swimming / Water Aerobics**
- Water buoyancy reduces joint impact by 75%
- Aim for 30 minutes, 3 times per week

**Cycling (Stationary)**
- Set seat height so knee bends only slightly at bottom of pedal stroke
- Low resistance, medium cadence
- 20–30 minutes, 3–5 times per week''',
  ),
  _Article(
    id: 'ex3',
    title: 'Range of Motion Exercises',
    summary: 'Stretches to maintain joint flexibility and reduce stiffness',
    icon: Icons.self_improvement_rounded,
    readTime: '3 min',
    content: '''Range of motion exercises maintain joint flexibility, reduce morning stiffness, and keep cartilage nourished.

Best done in the morning after applying gentle warmth to joints.

**Ankle Circles** — 10 circles each direction, each ankle

**Knee Flexion/Extension**
- Sit on chair, slowly straighten knee as far as comfortable
- Hold 5 seconds, lower slowly
- 10 reps each leg

**Hip Circles**
- Stand holding support
- Gently swing leg forward, to side, backward in controlled arc
- 10 reps each leg''',
  ),
];

const _dietArticles = [
  _Article(
    id: 'diet1',
    title: 'Anti-Inflammatory Foods',
    summary: 'Foods that help reduce joint inflammation and pain',
    icon: Icons.restaurant_menu_rounded,
    readTime: '4 min',
    content: '''Inflammation plays a major role in OA progression. Including anti-inflammatory foods can help manage symptoms.

**Include more of:**
- Fatty fish (salmon, mackerel, sardines) — rich in omega-3 fatty acids, 2–3 servings/week
- Mustard oil / olive oil — contains oleocanthal, which acts like ibuprofen
- Turmeric + black pepper — curcumin is a potent anti-inflammatory
- Berries, amla, citrus — vitamin C for collagen synthesis
- Leafy greens — spinach, fenugreek, methi leaves
- Ginger and garlic — natural anti-inflammatory compounds

**Limit:**
- Refined sugars and processed foods
- Excessive red meat
- Deep-fried foods''',
  ),
  _Article(
    id: 'diet2',
    title: 'Calcium & Vitamin D',
    summary: 'Essential nutrients for bone and joint health',
    icon: Icons.water_drop_rounded,
    readTime: '3 min',
    content: '''Adequate calcium and vitamin D are critical for maintaining bone density and joint health, especially in OA.

**Calcium Sources (aim for 1000–1200 mg/day):**
- Milk, curd, paneer, buttermilk
- Ragi (finger millet) — exceptional calcium source
- Drumstick leaves, amaranth leaves
- Bengal gram, rajma, black-eyed peas
- Small fish eaten with bones

**Vitamin D (aim for 600–800 IU/day):**
- Sun exposure: 15–20 minutes between 10 AM–2 PM, 3–4 times/week
- Egg yolk, fatty fish, mushrooms (sun-exposed)
- Fortified milk and cereals

Note: Vitamin D enhances calcium absorption — both are needed together.''',
  ),
  _Article(
    id: 'diet3',
    title: 'Weight Management Diet',
    summary: 'Every kilogram lost reduces knee joint load by 4 kg',
    icon: Icons.monitor_weight_outlined,
    readTime: '4 min',
    content: '''Excess body weight dramatically increases mechanical stress on weight-bearing joints. Even modest weight loss significantly reduces OA symptoms.

**Key Principles:**

Portion Control
- Use smaller plates
- Eat slowly — it takes 20 minutes for satiety signals to reach the brain
- Fill half the plate with vegetables

Reduce Calorie-Dense Foods
- Limit sweets, namkeens, and deep-fried snacks
- Replace white rice/bread with millets, jowar, bajra
- Avoid sugary drinks — replace with water, lassi, chaas

Increase Protein
- Protein helps maintain muscle mass which supports joints
- Include dal, eggs, paneer, or fish at every meal

Goal: Lose 5–10% of body weight if overweight. Even this much reduces knee pain by 20–30%.''',
  ),
];

const _lifestyleArticles = [
  _Article(
    id: 'life1',
    title: 'Joint Protection Techniques',
    summary: 'Daily habits to protect joints and prevent further damage',
    icon: Icons.shield_outlined,
    readTime: '4 min',
    content: '''Simple modifications in daily activities can significantly reduce joint stress and prevent OA progression.

**Sitting & Standing**
- Use chairs with armrests — push up using arms when rising
- Avoid sitting on the floor for extended periods
- Take a 5-minute movement break every 45 minutes of sitting

**Carrying & Lifting**
- Carry bags with shoulder strap, not hands
- Distribute weight — carry lighter loads in both hands
- Use wheeled bags/trolleys when possible

**Footwear**
- Always wear supportive, cushioned footwear — even at home
- Avoid flat chappals — they provide no arch support

**Sleeping Position**
- Sleep with a pillow between knees to maintain hip alignment
- Avoid sleeping on stomach (strains the spine)''',
  ),
  _Article(
    id: 'life2',
    title: 'Stress Management',
    summary: 'How stress affects joint pain and how to manage it',
    icon: Icons.spa_rounded,
    readTime: '4 min',
    content: '''Psychological stress worsens pain perception and inflammation, creating a vicious cycle in OA. Managing stress is an important part of OA care.

**Mindfulness & Breathing**
- 5 minutes of slow diaphragmatic breathing twice daily
- Box breathing: inhale 4 counts, hold 4, exhale 4, hold 4

**Yoga (Joint-Safe)**
- Yoga Nidra (body scan meditation) — no physical movement required
- Seated pranayama (breathing exercises)
- Gentle supine yoga poses
- Avoid deep squats, padmasana if knee pain is present

**Social Connection**
- Isolation worsens pain — stay socially active
- Join a health group or walking group in your village

**Sleep Hygiene**
- 7–8 hours of sleep is essential for tissue repair
- Maintain consistent sleep/wake times
- Avoid screens 1 hour before sleep''',
  ),
  _Article(
    id: 'life3',
    title: 'Heat & Cold Therapy',
    summary: 'When to use heat vs cold for joint pain relief',
    icon: Icons.thermostat_rounded,
    readTime: '4 min',
    content: '''Thermotherapy (heat) and cryotherapy (cold) are simple, effective, low-cost interventions for OA pain management.

**Heat Therapy — for chronic stiffness & muscle spasm**
- Best for: morning stiffness, chronic dull ache, muscle tension
- Method: warm towel, hot water bottle, or warm bath
- Apply for 15–20 minutes
- Do NOT use on acutely swollen/inflamed joints

**Cold Therapy — for acute swelling & inflammation**
- Best for: after exercise, acute flare-up, warm swollen joint
- Method: ice pack wrapped in cloth (never apply ice directly to skin)
- Apply for 10–15 minutes
- Rest 45 minutes before re-applying

**Safety:** Never apply directly to skin. Check skin frequently. Stop if pain increases.''',
  ),
];

class PreventiveCareCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String? categoryTitle;
  final LinearGradient? gradient;
  final IconData? icon;

  const PreventiveCareCategoryScreen({
    super.key,
    required this.categoryId,
    this.categoryTitle,
    this.gradient,
    this.icon,
  });

  List<_Article> get _articles {
    switch (categoryId) {
      case 'exercises': return _exercisesArticles;
      case 'diet': return _dietArticles;
      default: return _lifestyleArticles;
    }
  }

  // Lookup category metadata by ID (used when navigated via deep link / route)
  ({String title, LinearGradient gradient, IconData icon}) _lookupCategory() {
    switch (categoryId) {
      case 'exercises':
        return (
          title: 'Exercises',
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.fitness_center_rounded,
        );
      case 'diet':
        return (
          title: 'Diet & Nutrition',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF784E), Color(0xFFFFB199)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.restaurant_menu_rounded,
        );
      default:
        return (
          title: 'Lifestyle',
          gradient: const LinearGradient(
            colors: [Color(0xFF5B6EE8), Color(0xFF0D7377)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.self_improvement_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = _articles;
    // Resolve category metadata: use passed values or look up by ID
    final cat = _lookupCategory();
    final effectiveTitle = categoryTitle ?? cat.title;
    final effectiveGradient = gradient ?? cat.gradient;
    final effectiveIcon = icon ?? cat.icon;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Gradient app bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: effectiveGradient.colors.first,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: effectiveGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingLg, 56, AppSpacing.screenPaddingLg, AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(effectiveIcon, color: Colors.white, size: 32),
                        const SizedBox(height: 8),
                        Text(effectiveTitle, style: AppTypography.headlineSmall.copyWith(color: Colors.white, fontWeight: AppTypography.bold)),
                        Text('${articles.length} evidence-based articles', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = articles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _ArticleCard(article: article, gradient: effectiveGradient)
                        .animate(delay: (index * 80).ms)
                        .fadeIn(duration: AppMotion.standard)
                        .slideY(begin: 0.1, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),
                  );
                },
                childCount: articles.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _Article article;
  final LinearGradient gradient;

  const _ArticleCard({required this.article, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PreventiveCareArticleScreen(article: article, gradient: gradient),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(article.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.semiBold)),
                  const SizedBox(height: 4),
                  Text(article.summary, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(article.readTime, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Article {
  final String id;
  final String title;
  final String summary;
  final IconData icon;
  final String readTime;
  final String content;

  const _Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.readTime,
    required this.content,
  });
}
