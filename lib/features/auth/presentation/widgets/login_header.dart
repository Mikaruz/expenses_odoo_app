import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oh_expenses_app/config/config.dart';
import 'package:oh_expenses_app/features/auth/presentation/presentation.dart';

class LoginHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;

  const LoginHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      color: paperColor,
      child: ClipPath(
        clipper: WaveClipper(),
        child: Container(
          width: size.width,
          height: size.height * 0.31,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [inkColor, Color(0xFF6F3A13), mainColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              if (showBackButton)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1.02,
                          letterSpacing: -0.6,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
