
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final int delay;

  const AnimatedButton({
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    required this.delay,
    Key? key,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _controller.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _controller.reverse();
            widget.onPressed();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _controller.reverse();
          },
          child: Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: widget.isOutlined 
                  ? null 
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(12, 77, 161, 1),
                        Color.fromRGBO(28, 93, 177, 1),
                        Color.fromRGBO(41, 121, 209, 1),
                        Color.fromRGBO(64, 144, 227, 1),
                      ],
                    ),
                border: widget.isOutlined 
                  ? Border.all(color: Colors.white, width: 2) 
                  : null,
                boxShadow: _isPressed 
                  ? [] 
                  : [
                      BoxShadow(
                        color: Color.fromRGBO(12, 77, 161, 0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(
      delay: Duration(milliseconds: widget.delay),
      duration: 800.ms,
    ).slideX(
      begin: 0.3,
      end: 0,
      curve: Curves.easeOutQuad,
      duration: 800.ms,
      delay: Duration(milliseconds: widget.delay),
    );
  }
}
