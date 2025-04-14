import 'dart:convert';
import 'package:flutter/material.dart';

/// A widget that displays an app icon from a Base64 encoded string.
///
/// This widget takes a Base64 encoded [iconBase64] string, decodes it,
/// and displays it using [Image.memory]. It handles potential decoding errors
/// and provides placeholders or error icons.
class AppIconWidget extends StatelessWidget {
  /// The Base64 encoded string representation of the app icon.
  final String? iconBase64;

  /// The desired width of the icon widget.
  final double width;

  /// The desired height of the icon widget.
  final double height;

  /// Creates an [AppIconWidget].
  ///
  /// Requires [iconBase64]. Optional [width] and [height] default to 40.0.
  const AppIconWidget({
    super.key,
    required this.iconBase64,
    this.width = 40.0,
    this.height = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (iconBase64 != null && iconBase64!.isNotEmpty) {
      try {
        final imageBytes = base64Decode(iconBase64!);
        return Image.memory(
          imageBytes,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Consider logging the error here if needed
            return Tooltip(
              message: 'Error loading icon',
              child: Icon(Icons.broken_image,
                  size: width, color: Theme.of(context).colorScheme.error),
            );
          },
        );
      } catch (e) {
        // Consider logging the error here if needed
        return Tooltip(
          message: 'Error decoding icon',
          child: Icon(Icons.error_outline,
              size: width, color: Theme.of(context).colorScheme.error),
        );
      }
    } else {
      // Placeholder if iconBase64 is null or empty
      return Tooltip(
        message: 'Icon not available',
        child: SizedBox(width: width, height: height),
        // Or return a default Icon:
        // child: Icon(Icons.apps, size: width),
      );
    }
  }
}
