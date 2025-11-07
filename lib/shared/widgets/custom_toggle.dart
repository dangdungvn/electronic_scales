import 'package:flutter/material.dart';

/// Custom Toggle component với design từ component library
class CustomToggle extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const CustomToggle({
    super.key,
    required this.isOn,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null) ...[
          Expanded(
            child: Text(
              label!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.43,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2024),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        GestureDetector(
          onTap: onChanged != null ? () => onChanged!(!isOn) : null,
          child: Container(
            width: 45,
            height: 24,
            decoration: BoxDecoration(
              color: isOn ? const Color(0xFF006FFD) : const Color(0xFFD4D6DD),
              borderRadius: BorderRadius.circular(200),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
