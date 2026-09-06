import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_manager.dart';

class DhatuProgress extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const DhatuProgress({
    Key? key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 15,
  }) : super(key: key);

  @override
  State<DhatuProgress> createState() => _DhatuProgressState();
}

class _DhatuProgressState extends State<DhatuProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeManager>(context);

    if (theme.styleMode == ThemeStyleMode.neomorphism) {
      return _buildNeumorphicPulse(theme);
    } else {
      return _buildGlassmorphicSkeleton(theme);
    }
  }

  Widget _buildNeumorphicPulse(ThemeManager theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicSkeleton(ThemeManager theme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
