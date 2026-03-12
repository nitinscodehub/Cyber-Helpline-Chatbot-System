import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickReplyChip extends StatelessWidget {
  final String icon;
  final String label;
  final String? description;
  final VoidCallback onTap;
  final bool isSelected;

  const QuickReplyChip({
    super.key,
    required this.icon,
    required this.label,
    this.description,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.blue.shade100 
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected 
                    ? Colors.blue.shade400 
                    : Colors.blue.shade200,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.blue.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.blue.shade700 : null,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickReplyGrid extends StatelessWidget {
  final List<Map<String, String>> replies;
  final Function(String) onTap;
  final String? selectedValue;

  const QuickReplyGrid({
    super.key,
    required this.replies,
    required this.onTap,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: replies.map((reply) {
        final isSelected = selectedValue == reply['text'];
        return QuickReplyChip(
          icon: reply['icon']!,
          label: reply['text']!,
          description: reply['desc'],
          isSelected: isSelected,
          onTap: () => onTap(reply['text']!),
        );
      }).toList(),
    );
  }
}

class AnimatedQuickReplyChip extends StatefulWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  final Duration delay;

  const AnimatedQuickReplyChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedQuickReplyChip> createState() => _AnimatedQuickReplyChipState();
}

class _AnimatedQuickReplyChipState extends State<AnimatedQuickReplyChip> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: QuickReplyChip(
          icon: widget.icon,
          label: widget.label,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}