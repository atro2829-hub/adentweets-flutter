class HashtagExtractor {
  HashtagExtractor._();

  static final RegExp _hashtagRegex = RegExp(r'#(\S+)');

  static List<String> extract(String text) {
    final matches = _hashtagRegex.allMatches(text);
    final hashtags = <String>{};
    for (final match in matches) {
      final tag = match.group(1);
      if (tag != null && tag.isNotEmpty) {
        hashtags.add(tag.toLowerCase());
      }
    }
    return hashtags.toList();
  }

  static List<String> extractWithHash(String text) {
    final matches = _hashtagRegex.allMatches(text);
    final hashtags = <String>{};
    for (final match in matches) {
      final tag = match.group(0);
      if (tag != null && tag.isNotEmpty) {
        hashtags.add(tag);
      }
    }
    return hashtags.toList();
  }

  static int count(String text) {
    return _hashtagRegex.allMatches(text).length;
  }

  static bool contains(String text) {
    return _hashtagRegex.hasMatch(text);
  }
}