import 'package:flutter/material.dart';

class FullscreenLoader extends StatefulWidget {
  final String imagePath = 'img/logo.png';

  const FullscreenLoader({
    Key? key,
  }) : super(key: key);

  @override
  _FullscreenLoaderState createState() => _FullscreenLoaderState();
}

class _FullscreenLoaderState extends State<FullscreenLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Medium speed
    )..repeat(reverse: true); // Repeats the animation in reverse

    _animation = Tween<double>(
      begin: 0.8, // Start scale
      end: 1.2, // End scale
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
          },
          child: Image.asset(
            widget.imagePath,
            width: 150, // Adjust the size of the image as needed
            height: 150,
          ),
        ),
      ),
    );
  }
}
