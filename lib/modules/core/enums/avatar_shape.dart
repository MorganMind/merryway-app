import 'package:flutter/material.dart';

enum AvatarShape {
  roundedRectangle,
  circle,
  roundedSquare,
}

extension AvatarShapeExtension on AvatarShape {
  ShapeBorder get shapeBorder {
    switch (this) {
      case AvatarShape.roundedRectangle:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
      case AvatarShape.circle:
        return const CircleBorder();
      case AvatarShape.roundedSquare:
        return RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    }
  }

  Size get size {
    switch (this) {
      case AvatarShape.roundedRectangle:
        return const Size(27, 32);
      case AvatarShape.circle:
        return const Size(32, 32);
      case AvatarShape.roundedSquare:
        return const Size(32, 32);
    }
  }
} 