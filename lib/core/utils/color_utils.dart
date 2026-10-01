import 'package:flutter/material.dart';

class ColorUtils {
  /// Converts Hex string to Flutter Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Converts Flutter Color to Hex string
  static String toHex(Color color, {bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${color.alpha.toRadixString(16).padLeft(2, '0')}'
      '${color.red.toRadixString(16).padLeft(2, '0')}'
      '${color.green.toRadixString(16).padLeft(2, '0')}'
      '${color.blue.toRadixString(16).padLeft(2, '0')}';

  /// Converts Flutter blend mode to FFmpeg blend filter keyword
  static String toFfmpegBlend(String blendModeName) {
    switch (blendModeName) {
      case 'screen':
        return 'screen';
      case 'multiply':
        return 'multiply';
      case 'overlay':
        return 'overlay';
      case 'softLight':
        return 'softlight';
      case 'hardLight':
        return 'hardlight';
      case 'colorDodge':
        return 'dodge';
      case 'normal':
      default:
        return 'normal';
    }
  }
}
