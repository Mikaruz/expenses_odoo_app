import 'package:flutter/material.dart';
import 'package:oh_expenses_app/config/config.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onProfilePressed;

  const HomeAppBar({
    super.key,
    required this.userName,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: paperColor,
      titleSpacing: 20,
      toolbarHeight: 72,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rendiciones',
            style: TextStyle(
              color: mutedInkColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Hola, $userName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: inkColor,
              letterSpacing: -0.35,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            onTap: onProfilePressed,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: receiptColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: lineColor),
              ),
              child: const Icon(Icons.person_outline_rounded, color: inkColor),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
