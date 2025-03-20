import 'package:app/modules/user/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:app/modules/core/ui/widgets/navigation_sidebar.dart';

class AnimatedSidebar extends StatelessWidget {
  final bool isVisible;
  final bool isLoading;

  const AnimatedSidebar({
    required this.isVisible,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: (isVisible && !isLoading) ? 60 : 0,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: isLoading
            ? const Center()
            : NavigationSidebar(),
      ),
    );
  }
} 