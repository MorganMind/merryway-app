import 'package:flutter/material.dart';

class QuickControls extends StatelessWidget {
  final String currentWeather;
  final String currentTimeOfDay;
  final String currentDayOfWeek;
  final VoidCallback onCustomize;

  const QuickControls({
    super.key,
    required this.currentWeather,
    required this.currentTimeOfDay,
    required this.currentDayOfWeek,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQuickChip(
            context,
            _getWeatherEmoji(currentWeather),
            currentWeather.capitalize(),
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            context,
            _getTimeEmoji(currentTimeOfDay),
            currentTimeOfDay.capitalize(),
          ),
          const SizedBox(width: 8),
          _buildQuickChip(
            context,
            '📅',
            currentDayOfWeek.capitalize(),
          ),
          const SizedBox(width: 8),
          _buildActionChip(context, onCustomize),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String emoji, String label) {
    return Chip(
      avatar: Text(emoji, style: const TextStyle(fontSize: 16)),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      backgroundColor: const Color(0xFFE8F4F8),
      side: BorderSide.none,
    );
  }

  Widget _buildActionChip(BuildContext context, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: const Text('Customize'),
      avatar: const Icon(Icons.tune, size: 16),
      backgroundColor: const Color(0xFFFFE8F0),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFFB4D7E8),
          ),
    );
  }

  String _getWeatherEmoji(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'rainy':
        return '🌧️';
      case 'cloudy':
        return '☁️';
      default:
        return '☁️';
    }
  }

  String _getTimeEmoji(String time) {
    switch (time.toLowerCase()) {
      case 'morning':
        return '🌅';
      case 'afternoon':
        return '🌞';
      case 'evening':
        return '🌆';
      default:
        return '🌞';
    }
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}

