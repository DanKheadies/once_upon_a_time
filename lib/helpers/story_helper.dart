extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String capitalizeWords() {
    if (isEmpty) return '';
    return split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          // return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
          return '${word[0].toUpperCase()}${word.substring(1)}';
        })
        .join(' ');
  }
}
