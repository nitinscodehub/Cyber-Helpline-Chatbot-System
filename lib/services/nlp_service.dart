class NLPService {
  // Detect language (Hindi/English/Hinglish)
  static String detectLanguage(String text) {
    final hindiPattern = RegExp(r'[ऀ-ॿ]');
    if (hindiPattern.hasMatch(text)) {
      return 'hi';
    }
    return 'en';
  }
  
  // Extract keywords from message
  static List<String> extractKeywords(String text) {
    final keywords = <String>[];
    final lowerText = text.toLowerCase();
    
    // Financial keywords
    if (lowerText.contains('paise') || lowerText.contains('पैसे') || 
        lowerText.contains('money') || lowerText.contains('rupay')) {
      keywords.add('financial');
    }
    
    // UPI keywords
    if (lowerText.contains('upi') || lowerText.contains('gpay') || 
        lowerText.contains('phonepe') || lowerText.contains('paytm')) {
      keywords.add('upi');
    }
    
    // Social media keywords
    if (lowerText.contains('facebook') || lowerText.contains('fb') || 
        lowerText.contains('instagram') || lowerText.contains('whatsapp')) {
      keywords.add('social_media');
    }
    
    // Hack keywords
    if (lowerText.contains('hack') || lowerText.contains('चोरी') || 
        lowerText.contains('हैक')) {
      keywords.add('hacked');
    }
    
    // Emergency keywords
    if (lowerText.contains('blackmail') || lowerText.contains('धमकी') ||
        lowerText.contains('threat') || lowerText.contains('ब्लैकमेल')) {
      keywords.add('emergency');
    }
    
    return keywords;
  }
  
  // Calculate urgency score
  static int calculateUrgencyScore(String text) {
    int score = 0;
    final lowerText = text.toLowerCase();
    
    // Emergency indicators
    if (lowerText.contains('blackmail') || lowerText.contains('धमकी')) score += 40;
    if (lowerText.contains('paise chale gaye') || lowerText.contains('पैसे चले गए')) score += 30;
    if (lowerText.contains('otp')) score += 20;
    if (lowerText.contains('hack')) score += 15;
    
    // Time indicators
    if (lowerText.contains('abhi') || lowerText.contains('अभी') || 
        lowerText.contains('just now')) score += 10;
    
    // Emotional indicators
    if (lowerText.contains('help') || lowerText.contains('मदद') || 
        lowerText.contains('bachao') || lowerText.contains('बचाओ')) score += 5;
    
    return score;
  }
}