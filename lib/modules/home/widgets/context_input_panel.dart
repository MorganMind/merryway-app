import 'package:flutter/material.dart';

class ContextInputPanel extends StatefulWidget {
  final String initialWeather;
  final String initialTimeOfDay;
  final String initialDayOfWeek;
  final String initialPrompt;
  final Function(String weather, String timeOfDay, String dayOfWeek, String prompt)
      onApply;

  const ContextInputPanel({
    super.key,
    this.initialWeather = 'cloudy',
    this.initialTimeOfDay = 'afternoon',
    this.initialDayOfWeek = 'monday',
    this.initialPrompt = '',
    required this.onApply,
  });

  @override
  State<ContextInputPanel> createState() => _ContextInputPanelState();
}

class _ContextInputPanelState extends State<ContextInputPanel> {
  late String selectedWeather;
  late String selectedTimeOfDay;
  late String selectedDayOfWeek;
  late TextEditingController promptController;
  final FocusNode _focusNode = FocusNode();
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    selectedWeather = widget.initialWeather;
    selectedTimeOfDay = widget.initialTimeOfDay;
    selectedDayOfWeek = widget.initialDayOfWeek;
    promptController = TextEditingController(text: widget.initialPrompt);
    
    _focusNode.addListener(() {
      // Show settings when field is focused
      if (_focusNode.hasFocus && !_showSettings) {
        setState(() {
          _showSettings = true;
        });
      }
      // Don't auto-hide when losing focus - only hide via Apply button or manual action
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    promptController.dispose();
    super.dispose();
  }

  void _applyChanges() {
    widget.onApply(
      selectedWeather,
      selectedTimeOfDay,
      selectedDayOfWeek,
      promptController.text,
    );
    _focusNode.unfocus();
  }

  IconData _getWeatherIcon(String weather) {
    switch (weather) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'rainy':
        return Icons.umbrella;
      case 'cloudy':
        return Icons.cloud;
      default:
        return Icons.cloud;
    }
  }

  IconData _getTimeIcon(String time) {
    switch (time) {
      case 'morning':
        return Icons.wb_twilight;
      case 'afternoon':
        return Icons.wb_sunny_outlined;
      case 'evening':
        return Icons.nightlight;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prompt field - always visible
            TextField(
              controller: promptController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'deprecated input do not use',
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFB4D7E8), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: promptController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.send, size: 20),
                        onPressed: _applyChanges,
                        color: const Color(0xFFB4D7E8),
                      )
                    : null,
              ),
              maxLines: 1,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _applyChanges(),
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide send button
              },
            ),
            
            // Compact settings - show when focused
            if (_showSettings) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Weather icons
                  _buildIconSelector(
                    'sunny',
                    Icons.wb_sunny,
                    selectedWeather == 'sunny',
                    const Color(0xFFFDB827),
                    () => setState(() => selectedWeather = 'sunny'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconSelector(
                    'rainy',
                    Icons.umbrella,
                    selectedWeather == 'rainy',
                    const Color(0xFF4A90E2),
                    () => setState(() => selectedWeather = 'rainy'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconSelector(
                    'cloudy',
                    Icons.cloud,
                    selectedWeather == 'cloudy',
                    const Color(0xFF8B8B8B),
                    () => setState(() => selectedWeather = 'cloudy'),
                  ),
                  
                  const SizedBox(width: 16),
                  Container(width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                  const SizedBox(width: 16),
                  
                  // Time icons
                  _buildIconSelector(
                    'morning',
                    Icons.wb_twilight,
                    selectedTimeOfDay == 'morning',
                    const Color(0xFFFF9E6D),
                    () => setState(() => selectedTimeOfDay = 'morning'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconSelector(
                    'afternoon',
                    Icons.wb_sunny_outlined,
                    selectedTimeOfDay == 'afternoon',
                    const Color(0xFFFDB827),
                    () => setState(() => selectedTimeOfDay = 'afternoon'),
                  ),
                  const SizedBox(width: 8),
                  _buildIconSelector(
                    'evening',
                    Icons.nightlight,
                    selectedTimeOfDay == 'evening',
                    const Color(0xFF5C6BC0),
                    () => setState(() => selectedTimeOfDay = 'evening'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Day abbreviations
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
                ].asMap().entries.map((entry) {
                  final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
                  final dayShort = entry.value;
                  final dayFull = days[entry.key];
                  final isSelected = selectedDayOfWeek == dayFull;
                  
                  return GestureDetector(
                    onTap: () => setState(() => selectedDayOfWeek = dayFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFB4D7E8) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dayShort,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF8B8B8B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              
              // Apply button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    _applyChanges();
                    setState(() {
                      _showSettings = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB4D7E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector(
    String value,
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap, // Simple click handler - panel stays open automatically
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? color : const Color(0xFF8B8B8B),
        ),
      ),
    );
  }
}
