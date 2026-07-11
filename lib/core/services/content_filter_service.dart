class ModerationResult {
  final bool isAllowed;
  final String reason;

  ModerationResult(this.isAllowed, this.reason);
}

class ContentFilterService {
  // 🔥 THE ULTIMATE MEGA BAD WORDS BUNDLE 🔥
  // এতে ইংলিশ, বাংলা, হিন্দি এবং স্প্যামের বিশাল কালেকশন রয়েছে।
  static final Set<String> _badWords = {
    // 🔴 ENGLISH PROFANITY, SLURS & EXPLICIT CONTENT (A-Z)
    'anal', 'anus', 'arse', 'arsehole', 'ass', 'asses', 'asshole', 'assholes', 'asswipe',
    'bastard', 'bastards', 'bitch', 'bitches', 'bitching', 'blowjob', 'bollocks', 'boob', 'boobs',
    'breast', 'breasts', 'bugger', 'bullshit', 'chink', 'circlejerk', 'clit', 'clitoris', 'cock',
    'cocksucker', 'coon', 'crap', 'cum', 'cumshot', 'cunt', 'cunts', 'dildo', 'dildos', 'dick',
    'dickhead', 'dipshit', 'douche', 'douchebag', 'dumbass', 'dyke', 'fag', 'faggot', 'faggots',
    'fatass', 'fck', 'felching', 'fuck', 'fucked', 'fucker', 'fuckers', 'fucking', 'fucks', 'fuckup',
    'fudgepacker', 'gook', 'gringo', 'handjob', 'hardcoresex', 'hoe', 'homo', 'hooker', 'horny',
    'incest', 'jackass', 'jerkoff', 'jizz', 'kike', 'lesbo', 'macaca', 'masturbate', 'masturbating',
    'milf', 'molest', 'moron', 'motherfucker', 'motherfucking', 'muff', 'nazi', 'nigga', 'niggas',
    'nigger', 'niggers', 'nympho', 'orgasm', 'orgy', 'paedo', 'pedophile', 'pedo', 'pecker',
    'penis', 'piss', 'pissed', 'pissing', 'porn', 'porno', 'pornography', 'prick', 'pussy', 'pussies',
    'queer', 'rape', 'rapist', 'retard', 'retarded', 'rimjob', 'schlong', 'scrotum', 'semen', 'sex',
    'shag', 'shemale', 'shit', 'shite', 'shits', 'shitted', 'shitting', 'shitty', 'skank', 'slag',
    'slut', 'sluts', 'smut', 'snatch', 'sonofabitch', 'spic', 'tits', 'titties', 'tranny', 'twat',
    'vagina', 'vulva', 'wank', 'wanker', 'whore', 'whores', 'wtf', 'lmfao', 'stfu', 'gtfo', 'kys',

    // 🔴 BENGALI (BANGLISH) EXTREME PROFANITY & SLANGS
    'bal', 'baal', 'baler', 'baaler', 'bokachoda', 'bokachuda', 'bokacoda', 'boka', 'choda',
    'chod', 'chudi', 'chuda', 'chud', 'chodna', 'chodani', 'chudani', 'chudon', 'chudam',
    'chudte', 'chudbo', 'chudachudi', 'chudakhor', 'chuilla', 'banchod', 'banchud', 'bainchod',
    'bainchud', 'baimanchod', 'gandu', 'gandmarani', 'gand', 'gud', 'guder', 'putki', 'putkir',
    'pod', 'poder', 'madarchod', 'madharchod', 'madarcod', 'magi', 'magir', 'magiya', 'khanqi',
    'khanki', 'khankir', 'khankimagir', 'bara', 'barar', 'bichi', 'bichir', 'vesha', 'besha',
    'bhatar', 'boudichoda', 'lengta', 'nengta', 'suar', 'suorer', 'suarer', 'shuor', 'shuorer',
    'kutta', 'kuttar', 'kuti', 'shala', 'shalar', 'shali', 'shalir', 'haramjada', 'haramjadi',
    'harami', 'haramkhor', 'khandani', 'khankiput', 'nangta', 'chudil', 'tor', 'maare', 'baapre',

    // 🔴 HINDI / URDU (HINGLISH) EXTREME PROFANITY
    'bhenchod', 'behenchod', 'bhenchud', 'benchod', 'madarchod', 'madarchud', 'chutiya',
    'chutiye', 'randi', 'rand', 'raand', 'randwa', 'bhosdike', 'bhosdi', 'bhosadi', 'bhosadike',
    'bhosada', 'gaandu', 'gandu', 'gand', 'gandi', 'gandmasti', 'gandfati', 'gandfat', 'gandmarwa',
    'lund', 'laura', 'loda', 'lawda', 'louda', 'chut', 'choot', 'chutmarika', 'chudai', 'chudwa',
    'chudakkad', 'chod', 'chodenge', 'muth', 'muthi', 'muthal', 'harami', 'kuta', 'kuttiya',
    'kameena', 'kamina', 'betichod', 'machod', 'tatte', 'jhant', 'chinaal', 'bhadwa', 'bhadwe',
    'dalal', 'suar', 'suwar', 'bulla', 'katwa', 'katuwa', 'chammar', 'chamar', 'bhangi',

    // 🔴 SPAM, SCAM, FRAUD & PHISHING KEYWORDS
    'free coins', 'free diamonds', 'hack', 'hacked', 'hacker', 'phishing', 'click here',
    'win money', 'lottery', 'bank details', 'credit card', 'debit card', 'password', 'passwrd',
    'otp', 'send money', 'bkash me', 'nagad me', 'rocket me', 'paytm', 'gpay', 'upi id',
    'cash prize', 'giveaway winner', 'verify your account', 'claim your prize', 'earn money',
    'part time job', 'daily income', 'investment', 'crypto', 'bitcoin', 'binance', 'invest'
  };

  // 🔥 স্মার্ট নর্মালাইজেশন (ইউজারের সব চালাকি ধরার জন্য)
  static String _normalizeText(String text) {
    String normalized = text.toLowerCase();

    // স্পেশাল ক্যারেক্টারকে আসল অক্ষরে কনভার্ট করা (Leetspeak bypass)
    normalized = normalized.replaceAll('@', 'a')
        .replaceAll('\$', 's')
        .replaceAll('0', 'o')
        .replaceAll('1', 'i')
        .replaceAll('3', 'e')
        .replaceAll('4', 'a')
        .replaceAll('!', 'i')
        .replaceAll('5', 's')
        .replaceAll('7', 't')
        .replaceAll('8', 'b')
        .replaceAll('*', '');

    // সব স্পেস এবং সিম্বল মুছে ফেলা (যাতে m a g i বা m-a-g-i হয়ে যায় magi)
    normalized = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    return normalized;
  }

  static ModerationResult validate(String text) {
    if (text.isEmpty) return ModerationResult(true, '');

    final lowerText = text.toLowerCase();
    final noSpaceText = _normalizeText(text);

    // ১. Suspicious Link / Spam Check (লিংক শেয়ার করা সম্পূর্ণ নিষিদ্ধ)
    final RegExp linkRegex = RegExp(r'(http|https)://[^\s]+');
    if (linkRegex.hasMatch(lowerText) || lowerText.contains('www.') || lowerText.contains('.com')) {
      return ModerationResult(false, 'Security Alert: External links or websites are not allowed in chats.');
    }

    // ২. Mega Bad Word Check Loop
    for (final word in _badWords) {

      // চেক এ: নরমাল শব্দ চেক (\b দিয়ে সম্পূর্ণ শব্দ ম্যাপ করা)
      final RegExp normalRegex = RegExp(r'\b' + word + r'\b', caseSensitive: false);
      if (normalRegex.hasMatch(lowerText)) {
        return ModerationResult(false, 'Message blocked: Contains inappropriate language, profanity, or spam.');
      }

      // চেক বি: স্মার্ট বাইপাস চেক (স্পেস বা সিম্বল দিয়ে চালাকি করলে)
      // ৪ বা তার বেশি অক্ষরের শব্দের জন্য এটি খুব নিখুঁত কাজ করবে।
      if (word.length >= 4 && noSpaceText.contains(word)) {
        return ModerationResult(false, 'Message blocked: Inappropriate behavior detected.');
      }
    }

    // ৩. সেফ মেসেজ
    return ModerationResult(true, '');
  }
}