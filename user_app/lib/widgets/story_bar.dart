import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _StoryItem(
            isAdd: index == 0,
            name: index == 0 ? 'إضافة قصة' : 'مستخدم $index',
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
              )
              .slideX(
                begin: 0.1,
                end: 0,
                delay: Duration(milliseconds: index * 50),
                duration: const Duration(milliseconds: 300),
              );
        },
      ),
    );
  }
}

class _StoryItem extends StatelessWidget {
  final bool isAdd;
  final String name;

  const _StoryItem({
    required this.isAdd,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: isAdd ? const EdgeInsets.all(2) : const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isAdd
                          ? null
                          : LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.scaffoldBackground,
                        image: isAdd
                            ? null
                            : DecorationImage(
                                image: MemoryImage(
                                  base64Decode(AppConstants.defaultAvatar),
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                      child: isAdd
                          ? const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}