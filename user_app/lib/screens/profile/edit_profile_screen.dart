import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';
import 'package:adentweets_app/core/utils/validators.dart';
import 'package:adentweets_app/core/constants/app_constants.dart';
import 'package:adentweets_app/providers/auth_provider.dart';
import 'package:adentweets_app/services/database_service.dart';
import 'package:adentweets_app/services/image_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  String? _avatarBase64;
  String? _bannerBase64;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userData = ref.read(authProvider).userData;
    _nameController = TextEditingController(text: userData?.fullName ?? '');
    _usernameController = TextEditingController(text: userData?.username ?? '');
    _bioController = TextEditingController(text: userData?.bio ?? '');
    _avatarBase64 = userData?.avatarBase64;
    _bannerBase64 = userData?.bannerBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final imageService = ref.read(imageServiceProvider);
    try {
      final base64 = await imageService.pickFromGallery();
      if (base64 != null && mounted) {
        setState(() => _avatarBase64 = base64);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickBanner() async {
    final imageService = ref.read(imageServiceProvider);
    try {
      final base64 = await imageService.pickFromGallery();
      if (base64 != null && mounted) {
        setState(() => _bannerBase64 = base64);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.uid;
      if (userId == null) return;

      final db = ref.read(databaseServiceProvider);
      final updates = <String, dynamic>{
        'fullName': _nameController.text.trim(),
        'username': _usernameController.text.trim().toLowerCase(),
        'bio': _bioController.text.trim(),
      };

      if (_avatarBase64 != null) {
        updates['avatarBase64'] = _avatarBase64;
      }
      if (_bannerBase64 != null) {
        updates['bannerBase64'] = _bannerBase64;
      }

      await db.updateData('${AppConstants.usersPath}/$userId', updates);

      final updatedUser = authState.userData!.copyWith(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim().toLowerCase(),
        bio: _bioController.text.trim(),
        avatarBase64: _avatarBase64,
        bannerBase64: _bannerBase64,
      );
      ref.read(authProvider.notifier).updateUserData(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في تحديث الملف الشخصي'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.iconPrimary),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
        title: Text(
          'تعديل الملف الشخصي',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SizedBox(
              width: 60,
              height: 36,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? AppColors.surfaceVariant : AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'حفظ',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.surfaceElevated,
                  child: _bannerBase64 != null
                      ? Image.memory(
                          base64Decode(_bannerBase64!),
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined, size: 40, color: AppColors.iconTertiary),
                        ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickBanner,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: 20,
                  child: GestureDetector(
                    onTap: _isLoading ? null : _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.scaffoldBackground,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.surfaceVariant,
                            backgroundImage: _avatarBase64 != null
                                ? MemoryImage(base64Decode(_avatarBase64!))
                                : null,
                            child: _avatarBase64 == null
                                ? Icon(Icons.person, size: 28, color: AppColors.iconTertiary)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(color: AppColors.scaffoldBackground, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 56),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      hint: 'محمد أحمد',
                      icon: Icons.person_outline_rounded,
                      validator: Validators.displayName,
                      maxLength: AppConstants.maxDisplayNameLength,
                    ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _usernameController,
                      label: 'اسم المستخدم',
                      hint: 'mohammed_ahmed',
                      icon: Icons.alternate_email_rounded,
                      validator: Validators.username,
                      maxLength: AppConstants.maxUsernameLength,
                    ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'النبذة',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              '${_bioController.text.length}/${AppConstants.maxBioLength}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _bioController.text.length > AppConstants.maxBioLength
                                        ? AppColors.error
                                        : AppColors.textTertiary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 3,
                          maxLength: AppConstants.maxBioLength,
                          validator: Validators.bio,
                          enabled: !_isLoading,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                          decoration: InputDecoration(
                            hintText: 'أخبرنا عن نفسك...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                            prefixIcon: const Icon(Icons.info_outline_rounded, color: AppColors.iconSecondary, size: 20),
                            prefixIconConstraints: const BoxConstraints(minWidth: 48),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            counterText: '',
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLength: maxLength,
          enabled: !_isLoading,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textTertiary,
                ),
            prefixIcon: Icon(icon, color: AppColors.iconSecondary, size: 20),
            filled: true,
            fillColor: AppColors.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            counterText: '',
            errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ),
      ],
    );
  }
}