import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../theme/theme_manager.dart';

class DhatuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const DhatuCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    this.borderRadius = 20.0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    Widget cardContent;

    if (theme.styleMode == ThemeStyleMode.neomorphism) {
      cardContent = _buildNeumorphicCard(theme);
    } else {
      cardContent = _buildGlassmorphicCard(theme);
    }

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: GestureDetector(
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    return Padding(
      padding: margin,
      child: cardContent,
    );
  }

  Widget _buildNeumorphicCard(ThemeManager theme) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Light highlight shadow (top-left)
          BoxShadow(
            color: theme.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // Dark shadow (bottom-right)
          BoxShadow(
            color: theme.shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildGlassmorphicCard(ThemeManager theme) {
    // Glassmorphism uses ClipRRect and BackdropFilter
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Lightweight blur
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.white.withOpacity(0.2), // Semi-transparent background
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.white.withOpacity(0.4), // Thin light border
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Subtle drop shadow
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
