import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:adentweets_admin/core/theme/app_colors.dart';
import 'package:adentweets_admin/core/constants/app_constants.dart';
import 'package:adentweets_admin/core/utils/responsive_utils.dart';
import 'package:adentweets_admin/services/database_service.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _isLoading = true;
  bool _maintenanceMode = false;
  int _maxPostLength = 280;
  bool _autoVerify = false;
  String _contentFilter = '';
  String _autoVerifyRules = '';
  final _filterController = TextEditingController();
  final _rulesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final snapshot = await DatabaseService.get('settings');
      if (snapshot.exists && snapshot.value != null) {
        final map = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _maintenanceMode = map['maintenanceMode'] as bool? ?? false;
          _maxPostLength = map['maxPostLength'] as int? ?? 280;
          _autoVerify = map['autoVerify'] as bool? ?? false;
          _contentFilter = map['contentFilters'] as String? ?? '';
          _autoVerifyRules = map['autoVerifyRules'] as String? ?? '';
          _filterController.text = _contentFilter;
          _rulesController.text = _autoVerifyRules;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await DatabaseService.update('settings', {
        'maintenanceMode': _maintenanceMode,
        'maxPostLength': _maxPostLength,
        'autoVerify': _autoVerify,
        'contentFilters': _filterController.text,
        'autoVerifyRules': _rulesController.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.horizontalPadding(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: const Text('الإعدادات'),
          actions: [
            TextButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPrimary))
                  : Icon(Iconsax.save_2, color: AppColors.accentPrimary),
              label: Text('حفظ', style: TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
            : ListView(
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
                children: [
                  _SectionHeader(title: 'معلومات التطبيق'),
                  _InfoRow(label: 'اسم التطبيق', value: AppConstants.appName),
                  _InfoRow(label: 'الإصدار', value: AppConstants.appVersion),
                  _InfoRow(label: 'الحالة', value: 'متصل', valueColor: AppColors.success),
                  const SizedBox(height: 24),

                  _SectionHeader(title: 'إعدادات النظام'),
                  _SwitchItem(
                    label: 'وضع الصيانة',
                    subtitle: 'منع المستخدمين من الوصول للتطبيق',
                    value: _maintenanceMode,
                    onChanged: (v) => setState(() => _maintenanceMode = v),
                  ),
                  _SwitchItem(
                    label: 'توثيق تلقائي',
                    subtitle: 'توثيق الحسابات الجديدة تلقائياً',
                    value: _autoVerify,
                    onChanged: (v) => setState(() => _autoVerify = v),
                  ),
                  _SliderItem(
                    label: 'أقصى طول للمنشور',
                    value: _maxPostLength.toDouble(),
                    min: 100,
                    max: 1000,
                    divisions: 18,
                    onChanged: (v) => setState(() => _maxPostLength = v.toInt()),
                    displayValue: '$_maxPostLength حرف',
                  ),
                  const SizedBox(height: 24),

                  _SectionHeader(title: 'فلتر المحتوى'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _filterController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'كلمات ممنوعة',
                        hintText: 'أدخل الكلمات الممنوعة مفصولة بفواصل',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (v) => _contentFilter = v,
                    ),
                  ),
                  Text(
                    'سيتم حظر المنشورات التي تحتوي على هذه الكلمات',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

                  _SectionHeader(title: 'قواعد التوثيق التلقائي'),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextField(
                      controller: _rulesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'قواعد التوثيق',
                        hintText: 'مثال: minFollowers:100, minPosts:10',
                        alignLabelWithHint: true,
                      ),
                      onChanged: (v) => _autoVerifyRules = v,
                    ),
                  ),
                  Text(
                    'الحد الأدنى من المتابعين والمنشورات للتوثيق التلقائي',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.accentPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  const _SwitchItem({required this.label, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      activeColor: AppColors.accentPrimary,
    );
  }
}

class _SliderItem extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Function(double) onChanged;
  final String displayValue;
  const _SliderItem({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              Text(displayValue, style: TextStyle(color: AppColors.accentPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.accentPrimary,
          ),
        ],
      ),
    );
  }
}