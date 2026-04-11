extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String titleCase() {
    if (this.isEmpty) {
      return this;
    }
    return this.split(' ').map((word) => word.capitalize()).join(' ');
  }
}
