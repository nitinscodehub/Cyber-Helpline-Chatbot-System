class User {
  final String id;
  String name;
  String phone;
  String email;
  String? photoUrl;
  String language;
  bool isDarkMode;
  DateTime createdAt;
  int totalChats;
  int totalComplaints;
  int safetyScore;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.photoUrl,
    this.language = 'hi',
    this.isDarkMode = false,
    required this.createdAt,
    this.totalChats = 0,
    this.totalComplaints = 0,
    this.safetyScore = 100,
  });

  factory User.guest() {
    return User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest User',
      phone: '',
      email: '',
      createdAt: DateTime.now(),
    );
  }

  // ⚡ YEH COPYWITH METHOD ADD KARO (ye missing tha)
  User copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? language,
    bool? isDarkMode,
    int? totalChats,
    int? totalComplaints,
    int? safetyScore,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      createdAt: createdAt,
      totalChats: totalChats ?? this.totalChats,
      totalComplaints: totalComplaints ?? this.totalComplaints,
      safetyScore: safetyScore ?? this.safetyScore,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'photoUrl': photoUrl,
    'language': language,
    'isDarkMode': isDarkMode,
    'createdAt': createdAt.toIso8601String(),
    'totalChats': totalChats,
    'totalComplaints': totalComplaints,
    'safetyScore': safetyScore,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    phone: json['phone'],
    email: json['email'],
    photoUrl: json['photoUrl'],
    language: json['language'] ?? 'hi',
    isDarkMode: json['isDarkMode'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    totalChats: json['totalChats'] ?? 0,
    totalComplaints: json['totalComplaints'] ?? 0,
    safetyScore: json['safetyScore'] ?? 100,
  );
}