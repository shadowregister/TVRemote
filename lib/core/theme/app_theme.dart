import 'package:flutter/material.dart';

abstract class AppTheme {
  // Dark theme colors
  static const Color backgroundColor = Color(0xFF1E1E2E);
  static const Color surfaceColor = Color(0xFF1E1E2E);
  static const Color cardColor = Color(0xFF1E1E2E);
  static const Color shadowDark = Color(0xFF151521);
  static const Color shadowLight = Color(0xFF27273B);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E9A);
  static const Color textMuted = Color(0xFF5A5A6E);

  // Light theme colors
  static const Color backgroundColorLight = Color(0xFFE8EBF0);
  static const Color surfaceColorLight = Color(0xFFE8EBF0);
  static const Color shadowDarkLight = Color(0xFFBEC3CB);
  static const Color shadowLightLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF2D3748);
  static const Color textSecondaryLight = Color(0xFF718096);
  static const Color textMutedLight = Color(0xFFA0AEC0);

  // Accent color - Purple/Indigo (same for both themes)
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color accentColorLight = Color(0xFF8B83FF);

  // Status colors (same for both themes)
  static const Color successColor = Color(0xFF4ADE80);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color warningColor = Color(0xFFFFBE0B);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: accentColor,
          secondary: accentColorLight,
          surface: surfaceColor,
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimary,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textSecondary,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: backgroundColorLight,
        colorScheme: const ColorScheme.light(
          primary: accentColor,
          secondary: accentColorLight,
          surface: surfaceColorLight,
          error: errorColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimaryLight,
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: textPrimaryLight),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimaryLight,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimaryLight,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimaryLight,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimaryLight,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimaryLight,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textSecondaryLight,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: textSecondaryLight,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMutedLight,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}

// Helper to get theme-aware colors
class NeumorphicColors {
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.backgroundColor
        : AppTheme.backgroundColorLight;
  }

  static Color getShadowDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.shadowDark
        : AppTheme.shadowDarkLight;
  }

  static Color getShadowLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.shadowLight
        : AppTheme.shadowLightLight;
  }

  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.textPrimary
        : AppTheme.textPrimaryLight;
  }

  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.textSecondary
        : AppTheme.textSecondaryLight;
  }

  static Color getTextMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppTheme.textMuted
        : AppTheme.textMutedLight;
  }
}

// Neumorphic container widget
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isPressed;
  final double depth;
  final Color? color;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.isPressed = false,
    this.depth = 6,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: shadowDark,
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                ),
                BoxShadow(
                  color: shadowLight,
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowDark,
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                ),
                BoxShadow(
                  color: shadowLight,
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                ),
              ],
      ),
      child: child,
    );
  }
}

// Neumorphic button
class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double size;
  final double borderRadius;
  final bool isCircle;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = 60,
    this.borderRadius = 16,
    this.isCircle = false,
    this.accentColor,
    this.padding,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.isCircle ? widget.size / 2 : widget.borderRadius;
    final bgColor = widget.accentColor ?? NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.isCircle ? widget.size : null,
        height: widget.isCircle ? widget.size : null,
        padding: widget.padding ?? (widget.isCircle ? null : const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: shadowDark.withOpacity(0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                  BoxShadow(
                    color: shadowLight.withOpacity(0.3),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// Neumorphic icon button
class NeumorphicIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? iconColor;
  final bool isAccent;
  final String? label;

  const NeumorphicIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 56,
    this.iconColor,
    this.isAccent = false,
    this.label,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isAccent ? AppTheme.accentColor : NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);
    final textPrimary = NeumorphicColors.getTextPrimary(context);
    final textMuted = NeumorphicColors.getTextMuted(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: shadowDark.withOpacity(0.8),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                      BoxShadow(
                        color: shadowLight.withOpacity(0.3),
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: shadowDark,
                        offset: const Offset(5, 5),
                        blurRadius: 10,
                      ),
                      BoxShadow(
                        color: shadowLight,
                        offset: const Offset(-5, -5),
                        blurRadius: 10,
                      ),
                    ],
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? (widget.isAccent ? Colors.white : textPrimary),
              size: widget.size * 0.4,
            ),
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 11,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// Neumorphic pressed/inset container
class NeumorphicInset extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const NeumorphicInset({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = NeumorphicColors.getBackground(context);
    final shadowDark = NeumorphicColors.getShadowDark(context);
    final shadowLight = NeumorphicColors.getShadowLight(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowDark,
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: shadowLight,
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              shadowDark.withOpacity(0.3),
              Colors.transparent,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

// Connection status indicator
class StatusIndicator extends StatelessWidget {
  final bool isConnected;
  final double size;

  const StatusIndicator({
    super.key,
    required this.isConnected,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isConnected ? AppTheme.successColor : AppTheme.textMuted,
        shape: BoxShape.circle,
        boxShadow: isConnected
            ? [
                BoxShadow(
                  color: AppTheme.successColor.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}
