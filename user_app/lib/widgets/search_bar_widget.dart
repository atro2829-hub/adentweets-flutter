import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adentweets_app/core/theme/app_colors.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autoFocus;
  final bool showBackButton;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onChanged,
    this.hintText = 'ابحث في عدن تويتر',
    this.autoFocus = false,
    this.showBackButton = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _isFocused ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          if (widget.showBackButton)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.iconPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
              padding: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              onSubmitted: widget.onSubmitted,
              onChanged: widget.onChanged,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiary,
                    ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppColors.iconSecondary,
                size: 18,
              ),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              padding: const EdgeInsets.only(left: 8),
              constraints: const BoxConstraints(),
            )
              .animate()
              .fadeIn(duration: 150.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 200.ms),
        ],
      ),
    ).animate().scale(
      begin: _isFocused ? const Offset(1.0, 1.0) : null,
      end: _isFocused ? const Offset(1.02, 1.02) : null,
      duration: 200.ms,
    );
  }
}