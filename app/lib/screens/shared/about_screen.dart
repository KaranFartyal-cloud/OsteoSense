import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('App Purpose'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'JointSaathi is an AI-assisted early detection app for Osteoarthritis (OA) risk screening, designed specifically for healthcare workers in rural and remote areas of the North Eastern Region (NER) of India.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Key Features'),
          _buildFeatureItem(Icons.offline_pin, 'Offline-first architecture'),
          _buildFeatureItem(Icons.psychology, 'AI-powered risk assessment'),
          _buildFeatureItem(Icons.directions_walk, 'Gait analysis using phone sensors'),
          _buildFeatureItem(Icons.translate, 'Multilingual support (English & Hindi)'),
          _buildFeatureItem(Icons.picture_as_pdf, 'PDF report generation'),
          _buildFeatureItem(Icons.cloud_sync, 'Automatic data sync'),
          const SizedBox(height: 24),
          _buildSectionTitle('Problem Statement'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Osteoarthritis is a major health concern in India, particularly in rural areas where access to specialist healthcare is limited. JointSaathi aims to bridge this gap by enabling early detection through AI-assisted screening that can be performed by frontline healthcare workers.',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Team Credits'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamMember('Development Team', 'JointSaathi Development'),
                  _buildTeamMember('AI/ML Team', 'TFLite Model Development'),
                  _buildTeamMember('Healthcare Advisors', 'Medical Consultation'),
                  _buildTeamMember('NER Healthcare Initiative', 'MDoNER Support'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2024 JointSaathi. All rights reserved.',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String role, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
