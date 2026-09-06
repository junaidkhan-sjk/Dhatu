import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../theme/theme_manager.dart';

class DhatuButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isPrimary; // True = uses primary color, False = uses background color

  const DhatuButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  State<DhatuButton> createState() => _DhatuButtonState();
}

class _DhatuButtonState extends State<DhatuButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);
    
    // Fallback tap target size for outdoor/gloved use is handled by Container padding
    // We also use a GestureDetector to handle custom pressed states manually

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minWidth: 48.0, minHeight: 48.0),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        decoration: _buildDecoration(theme),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.isPrimary ? theme.onPrimaryColor : theme.primaryColor,
                ),
              )
            else ...[
              Icon(
                widget.icon,
                color: _getTextColor(theme),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 18, // Large touch targets/readable text
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(theme),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Color _getTextColor(ThemeManager theme) {
    if (widget.isPrimary) return theme.onPrimaryColor;
    return theme.textColor;
  }

  BoxDecoration _buildDecoration(ThemeManager theme) {
    if (theme.styleMode == ThemeStyleMode.neomorphism) {
      return _buildNeumorphicDecoration(theme);
    } else {
      return _buildGlassmorphicDecoration(theme);
    }
  }

  BoxDecoration _buildNeumorphicDecoration(ThemeManager theme) {
    final bgColor = widget.isPrimary ? theme.primaryColor : theme.backgroundColor;
    
    // For neomorphism, a pressed button uses inset shadows, but Flutter's default BoxShadow doesn't support inset easily.
    // Instead, we simulate it by removing shadows and slightly darkening when pressed.
    return BoxDecoration(
      color: _isPressed ? bgColor.withOpacity(0.9) : bgColor,
      borderRadius: BorderRadius.circular(30.0),
      boxShadow: _isPressed
          ? [] // "Pressed in" state
          : [
              BoxShadow(
                color: theme.shadowLight,
                offset: const Offset(-4, -4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: theme.shadowDark,
                offset: const Offset(4, 4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
    );
  }

  BoxDecoration _buildGlassmorphicDecoration(ThemeManager theme) {
    final bgColor = widget.isPrimary ? theme.primaryColor : (theme.isDarkMode ? Colors.black26 : Colors.white24);
    
    return BoxDecoration(
      color: _isPressed ? bgColor.withOpacity(0.5) : bgColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(30.0),
      border: Border.all(
        color: Colors.white.withOpacity(0.4),
        width: 1.0,
      ),
      boxShadow: [
        if (!_isPressed)
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          )
      ],
    );
  }
}
