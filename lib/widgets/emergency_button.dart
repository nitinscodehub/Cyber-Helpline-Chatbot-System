import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmergencyButton extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;
  final Color color;
  final bool isLarge;
  final VoidCallback? onTap;

  const EmergencyButton({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
    required this.color,
    this.isLarge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        width: isLarge ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 24 : 16,
          vertical: isLarge ? 16 : 12,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isLarge ? 28 : 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: GoogleFonts.poppins(
                    fontSize: isLarge ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: isLarge ? 14 : 12,
                    color: color.withAlpha(204),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EmergencyFloatingButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed ?? () {},
      icon: const Icon(Icons.warning_rounded, color: Colors.white),
      label: const Text('EMERGENCY'),
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 4,
    );
  }
}

class EmergencyBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const EmergencyBadge({super.key, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  final String title;
  final String description;
  final String number;
  final VoidCallback? onCall;

  const EmergencyCard({
    super.key,
    required this.title,
    required this.description,
    required this.number,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, color: Colors.white),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            description,
            style: GoogleFonts.poppins(color: Colors.white.withAlpha(230)),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: onCall,
        ),
      ),
    );
  }
}