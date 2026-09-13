import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({Key? key, required this.priority}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = Color(0xFFEF4444);
        label = 'HIGH';
        icon = Icons.local_fire_department_rounded;
        break;
      case 'medium':
        badgeColor = Color(0xFFF59E0B);
        label = 'MED';
        icon = Icons.bolt_rounded;
        break;
      case 'low':
      default:
        badgeColor = Color(0xFF10B981);
        label = 'LOW';
        icon = Icons.eco_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: badgeColor),
          SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
