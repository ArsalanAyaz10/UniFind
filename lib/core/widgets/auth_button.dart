import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color; // Make color optional (nullable)

  CustomButton({
    super.key,
    this.color,
    required this.text,
    required this.onPressed,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        _isPressed
            ? [Colors.orange.shade700, Colors.deepOrange.shade400]
            : _isHovered
            ? [Colors.orange.shade300, Colors.deepOrange.shade200]
            : [
              Color.fromARGB(255, 255, 204, 128),
              Color.fromARGB(255, 255, 153, 51),
            ];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:
          (_) => setState(() {
            _isHovered = false;
            _isPressed = false;
          }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient:
                widget.color == null
                    ? LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null, // If a solid color is provided, skip gradient
            color: widget.color, // Use solid color if provided
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              if (_isPressed)
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          child: Center(
            child: Text(
              widget.text,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
