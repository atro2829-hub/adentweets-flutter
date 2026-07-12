class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!regex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    if (trimmed.length > 20) {
      return 'اسم المستخدم يجب أن لا يتجاوز 20 حرفًا';
    }
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(trimmed)) {
      return 'اسم المستخدم يمكن أن يحتوي على أحرف إنجليزية وأرقام وشرطة سفلية فقط';
    }
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم المعروض مطلوب';
    }
    if (value.trim().length > 50) {
      return 'الاسم المعروض يجب أن لا يتجاوز 50 حرفًا';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }

  static String? postContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'محتوى المنشور مطلوب';
    }
    if (value.length > 280) {
      return 'المنشور يجب أن لا يتجاوز 280 حرفًا';
    }
    return null;
  }

  static String? commentContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'محتوى التعليق مطلوب';
    }
    if (value.length > 500) {
      return 'التعليق يجب أن لا يتجاوز 500 حرف';
    }
    return null;
  }

  static String? bio(String? value) {
    if (value != null && value.length > 160) {
      return 'النبذة يجب أن لا تتجاوز 160 حرفًا';
    }
    return null;
  }
}