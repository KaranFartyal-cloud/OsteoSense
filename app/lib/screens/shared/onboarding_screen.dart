import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.medical_services,
      title: 'Early Detection',
      description: 'Detect osteoarthritis risk early with AI-powered screening',
    ),
    OnboardingItem(
      icon: Icons.cloud_off,
      title: 'Offline First',
      description: 'Works without internet, syncs when connection available',
    ),
    OnboardingItem(
      icon: Icons.location_on,
      title: 'Rural Healthcare',
      description: 'Designed for healthcare workers in remote areas',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isHindi = settingsProvider.language == 'hi';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index], isHindi);
                },
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            item.icon,
            size: 120,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 32),
          Text(
            isHindi ? _getHindiTitle(item.title) : item.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isHindi ? _getHindiDescription(item.description) : item.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _items.length,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _items.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  child: Text(_currentPage < _items.length - 1 ? 'Next' : 'Get Started'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_currentPage < _items.length - 1)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryColor : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String _getHindiTitle(String englishTitle) {
    switch (englishTitle) {
      case 'Early Detection':
        return 'प्रारंभिक पहचान';
      case 'Offline First':
        return 'ऑफ़लाइन पहले';
      case 'Rural Healthcare':
        return 'ग्रामीण स्वास्थ्य सेवा';
      default:
        return englishTitle;
    }
  }

  String _getHindiDescription(String englishDescription) {
    switch (englishDescription) {
      case 'Detect osteoarthritis risk early with AI-powered screening':
        return 'AI-संचालित स्क्रीनिंग के साथ ऑस्टियोआर्थराइटिस जोखिम का प्रारंभिक पता लगाएं';
      case 'Works without internet, syncs when connection available':
        return 'बिना इंटरनेट के काम करता है, कनेक्शन उपलब्ध होने पर सिंक होता है';
      case 'Designed for healthcare workers in remote areas':
        return 'दूरदराज के क्षेत्रों में स्वास्थ्य कार्यकर्ताओं के लिए डिज़ाइन किया गया';
      default:
        return englishDescription;
    }
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
