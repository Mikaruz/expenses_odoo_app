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
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: mainColor.withOpacity(0.1),
            child: const Icon(Icons.person, color: mainColor),
          ),
          const SizedBox(width: 12),
          Text(
            'Hola, $userName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onProfilePressed,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=12', // Placeholder
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
