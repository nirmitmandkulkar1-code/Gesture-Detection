import 'package:flutter/material.dart';
import '../models/gesture_sign.dart';

class SignCard extends StatelessWidget {
  const SignCard({
    super.key,
    required this.sign,
    required this.isSelected,
    required this.onTap,
  });

  final GestureSign sign;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  sign.color.withOpacity(0.9),
                  sign.color.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFDFEFF), Color(0xFFF3F8FB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isSelected
              ? sign.color.withOpacity(0.75)
              : sign.color.withOpacity(0.22),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: sign.color.withOpacity(isSelected ? 0.22 : 0.08),
            blurRadius: isSelected ? 20 : 12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12), // Slightly reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18, // Slightly smaller
                      backgroundColor: isSelected
                          ? Colors.white.withOpacity(0.22)
                          : sign.color.withOpacity(0.12),
                      child: Icon(
                        sign.icon,
                        size: 18,
                        color: isSelected ? Colors.white : sign.color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '#${sign.id}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : sign.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  sign.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isSelected ? Colors.white : const Color(0xFF19354A),
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    sign.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.92)
                          : const Color(0xFF486378),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
