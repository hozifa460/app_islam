class Fatwa {
  final String id;
  final String question;
  final String answer;
  final String scholar;
  final String book;
  final String category;
  final List<String> keywords;
  final String source;
  final String url;
  final String title;
  final String audio;
  final List<String> categories;

  Fatwa({
    required this.id,
    required this.question,
    required this.answer,
    this.scholar = '',
    this.book = '',
    this.category = '',
    this.keywords = const [],
    this.source = '',
    this.url = '',
    this.title = '',
    this.audio = '',
    this.categories = const [],
  });

  factory Fatwa.fromJson(Map<String, dynamic> json) {
    // استخراج التصنيفات
    List<String> cats = [];
    if (json['categories'] != null) {
      cats = List<String>.from(json['categories']);
    }

    // التصنيف الرئيسي
    String mainCategory = '';
    if (json['category'] != null && json['category'].toString().isNotEmpty) {
      mainCategory = json['category'].toString();
    } else if (cats.isNotEmpty) {
      mainCategory = cats.first;
    } else {
      mainCategory = 'عام';
    }

    // السؤال: نأخذه من question أو title
    String questionText = '';
    if (json['question'] != null && json['question'].toString().length > 5) {
      questionText = json['question'].toString();
    } else if (json['title'] != null) {
      questionText = json['title'].toString();
    }

    // الرابط: نأخذه من url أو link
    String urlText = '';
    if (json['url'] != null && json['url'].toString().isNotEmpty) {
      urlText = json['url'].toString();
    } else if (json['link'] != null) {
      urlText = json['link'].toString();
    }

    // المصدر
    String sourceText = '';
    if (json['source'] != null && json['source'].toString().isNotEmpty) {
      sourceText = json['source'].toString();
    } else if (json['book'] != null && json['book'].toString().isNotEmpty) {
      sourceText = json['book'].toString();
    } else if (json['scholar'] != null) {
      sourceText = json['scholar'].toString();
    }

    // الكلمات المفتاحية
    List<String> keywordsList = [];
    if (json['keywords'] != null) {
      keywordsList = List<String>.from(json['keywords']);
    }

    return Fatwa(
      id: json['id']?.toString() ?? '',
      question: questionText,
      answer: json['answer']?.toString() ?? '',
      scholar: json['scholar']?.toString() ?? '',
      book: json['book']?.toString() ?? sourceText,
      category: mainCategory,
      keywords: keywordsList,
      source: sourceText,
      url: urlText,
      title: json['title']?.toString() ?? questionText,
      audio: json['audio']?.toString() ?? '',
      categories: cats,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'title': title,
    'answer': answer,
    'scholar': scholar,
    'book': book,
    'category': category,
    'categories': categories,
    'keywords': keywords,
    'source': source,
    'url': url,
    'audio': audio,
  };

  // نص البحث الكامل
  String get searchableText {
    return '$question $title $answer ${keywords.join(" ")} ${categories.join(" ")}';
  }

  // هل لها صوت؟
  bool get hasAudio => audio.isNotEmpty;

  // هل لها رابط؟
  bool get hasUrl => url.isNotEmpty;
}
