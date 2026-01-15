import 'package:flutter/material.dart';
import 'package:news_reader/core/theme/app_theme.dart';

/// Footer Widget - Professional footer untuk aplikasi
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final year = DateTime.now().year;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        gradient: isDark 
            ? AppTheme.darkGradient 
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                  isDark ? AppTheme.darkBackground : AppTheme.lightSurface,
                ],
              ),
      ),
      child: Column(
        children: [
          // App Logo/Name
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.newspaper,
              color: Colors.white,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'News Reader Pro',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Stay informed with news from multiple trusted sources',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark 
                  ? AppTheme.darkTextSecondary 
                  : AppTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Powered by APIs
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAPIBadge('GNews', isDark),
              _buildAPIBadge('NewsAPI', isDark),
              _buildAPIBadge('Currents', isDark),
              _buildAPIBadge('NewsData', isDark),
              _buildAPIBadge('Mediastack', isDark),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Divider(),
          
          const SizedBox(height: 16),
          
          // Copyright
          Text(
            '© $year News Reader Pro. All rights reserved.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Made with Flutter 💙',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIBadge(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark 
            ? AppTheme.darkCard.withOpacity(0.5)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.3),
        ),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}