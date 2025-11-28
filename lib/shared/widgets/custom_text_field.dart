import 'package:flutter/material.dart';

enum TextFieldState { active, inactive }

class CustomTextField extends StatefulWidget {
  final TextFieldState state;
  final String? title;
  final String? placeholder;
  final String? supportText;
  final String? unit;
  final Widget? icon;
  final bool showTitle;
  final bool showSupportText;
  final bool showUnit;
  final bool showIcon;
  final bool showPlaceholder;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onIconTap;
  final String? Function(String?)? validator;
  final bool hasError;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool obscureText;

  const CustomTextField({
    super.key,
    this.state = TextFieldState.active,
    this.title,
    this.placeholder,
    this.supportText,
    this.unit,
    this.icon,
    this.showTitle = true,
    this.showSupportText = false,
    this.showUnit = false,
    this.showIcon = false,
    this.showPlaceholder = true,
    this.controller,
    this.onChanged,
    this.onIconTap,
    this.validator,
    this.hasError = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.obscureText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInactive = widget.state == TextFieldState.inactive;
    final isError = widget.hasError;
    final isFocused = _isFocused && !isInactive;

    // Border colors and widths based on state
    Color borderColor;
    double borderWidth;

    if (isInactive) {
      borderColor = const Color(0xFFC5C6CC); // Neutral/Light/Darkest
      borderWidth = 1;
    } else if (isError) {
      borderColor = const Color(0xFFFF616D); // Support/Error/Medium
      borderWidth = 1.5;
    } else if (isFocused) {
      borderColor = const Color(0xFF006FFD); // Highlight/Darkest
      borderWidth = 1.5;
    } else {
      borderColor = const Color(0xFFC5C6CC); // Neutral/Light/Darkest
      borderWidth = 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        if (widget.showTitle && widget.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.title!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.21,
                fontWeight: FontWeight.w700,
                color: isInactive
                    ? const Color(0xFF8F9098) // Neutral/Dark/Lightest
                    : const Color(0xFF2F3036), // Neutral/Dark/Dark
              ),
            ),
          ),

        // Field
        Container(
          constraints: BoxConstraints(
            minHeight: widget.maxLines != null && widget.maxLines! > 1
                ? 96
                : 44,
          ),
          decoration: BoxDecoration(
            color: isInactive
                ? const Color(0xFFF8F9FE) // Neutral/Light/Light
                : Colors.white,
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit (if shown)
              if (widget.showUnit && widget.unit != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    widget.unit!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.43,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8F9098), // Neutral/Dark/Lightest
                    ),
                  ),
                ),

              // Text input
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  enabled: !isInactive,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  keyboardType: widget.keyboardType,
                  textCapitalization: widget.textCapitalization,
                  maxLines: widget.maxLines,
                  obscureText: widget.obscureText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.43,
                    fontWeight: FontWeight.w400,
                    color: isInactive
                        ? const Color(0xFF8F9098) // Neutral/Dark/Lightest
                        : const Color(0xFF1F2024), // Neutral/Dark/Darkest
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.showPlaceholder
                        ? widget.placeholder
                        : null,
                    hintStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      height: 1.43,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8F9098), // Neutral/Dark/Lightest
                    ),
                  ),
                  cursorColor: const Color(0xFF006FFD), // Highlight/Darkest
                  cursorWidth: 1.5,
                ),
              ),

              // Icon (if shown)
              if (widget.showIcon && widget.icon != null)
                GestureDetector(
                  onTap: widget.onIconTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: SizedBox(width: 16, height: 16, child: widget.icon),
                  ),
                ),
            ],
          ),
        ),

        // Support text
        if (widget.showSupportText && widget.supportText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.supportText!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                height: 1.21,
                letterSpacing: 0.15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8F9098), // Neutral/Dark/Lightest
              ),
            ),
          ),
      ],
    );
  }
}

// Eye icon for visibility toggle
class EyeIcon extends StatelessWidget {
  final bool isVisible;

  const EyeIcon({super.key, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: EyeIconPainter(isVisible: isVisible),
    );
  }
}

class EyeIconPainter extends CustomPainter {
  final bool isVisible;

  EyeIconPainter({required this.isVisible});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF8F9098) // Neutral/Dark/Lightest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    if (isVisible) {
      // Draw eye outline
      final path = Path();
      path.moveTo(size.width * 0.02, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.16,
        size.width * 0.98,
        size.height * 0.5,
      );
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.84,
        size.width * 0.02,
        size.height * 0.5,
      );
      canvas.drawPath(path, paint);

      // Draw pupil
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        size.width * 0.19,
        paint,
      );
    } else {
      // Draw eye with slash
      final path = Path();
      path.moveTo(size.width * 0.02, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.16,
        size.width * 0.98,
        size.height * 0.5,
      );
      path.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.84,
        size.width * 0.02,
        size.height * 0.5,
      );
      canvas.drawPath(path, paint);

      // Draw slash line
      canvas.drawLine(
        Offset(size.width * 0.15, size.height * 0.15),
        Offset(size.width * 0.85, size.height * 0.85),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(EyeIconPainter oldDelegate) =>
      isVisible != oldDelegate.isVisible;
}
