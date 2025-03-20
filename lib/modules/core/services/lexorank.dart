class LexoRank {
  // Using digits and lowercase letters for more possible values
  static const String DIGITS = '0123456789abcdefghijklmnopqrstuvwxyz';
  static const int BASE = 36; // Number of characters in DIGITS
  static const String MID_POINT = 'i0'; // Middle of the ordering space
  static const int SEGMENT_LENGTH = 6; // Length of each segment
  
  // Generate a rank between two other ranks
  static String between(String? before, String? after) {
    if (before == null && after == null) {
      return MID_POINT;
    }
    
    if (before == null) {
      // Insert at start - generate rank before 'after'
      return _generateBefore(after!);
    }
    
    if (after == null) {
      // Insert at end - generate rank after 'before'
      return _generateAfter(before);
    }
    
    // Find rank between before and after
    return _generateBetween(before, after);
  }
  
  static String _generateBefore(String rank) {
    if (rank.isEmpty) return '';
    final numeric = _toNumeric(rank);
    return _formatNumeric(numeric - _gap(rank.length));
  }
  
  static String _generateAfter(String rank) {
    if (rank.isEmpty) return '';
    final numeric = _toNumeric(rank);
    return _formatNumeric(numeric + _gap(rank.length));
  }
  
  static String _generateBetween(String before, String after) {
    final beforeNum = _toNumeric(before);
    final afterNum = _toNumeric(after);
    final gap = afterNum - beforeNum;
    
    if (gap <= 1) {
      // If gap is too small, extend the string
      return before + _formatNumeric(_gap(1));
    }
    
    return _formatNumeric(beforeNum + (gap ~/ 2));
  }
  
  static int _toNumeric(String rank) {
    int result = 0;
    for (int i = 0; i < rank.length; i++) {
      result = result * BASE + DIGITS.indexOf(rank[i]);
    }
    return result;
  }
  
  static String _formatNumeric(int value) {
    if (value == 0) return DIGITS[0];
    
    String result = '';
    while (value > 0) {
      result = DIGITS[value % BASE] + result;
      value = value ~/ BASE;
    }
    return result;
  }
  
  static int _gap(int length) {
    return BASE ~/ 2;
  }

  static int compare(String a, String b) {
    return a.compareTo(b); // Simple string comparison works because of how lexoranks are structured
  }
}