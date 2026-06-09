import 'package:flutter/material.dart';

class ColorHelper {
  static Color getContrastColor(Color backgroundColor) {
    // Calculate luminance
    final double luminance = (0.299 * backgroundColor.red +
        0.587 * backgroundColor.green +
        0.114 * backgroundColor.blue) / 255;
    
    // Return white for dark backgrounds, black for light backgrounds
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  static bool isLightColor(Color color) {
    final double luminance = (0.299 * color.red +
        0.587 * color.green +
        0.114 * color.blue) / 255;
    return luminance > 0.5;
  }
}
