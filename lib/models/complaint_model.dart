class Complaint {
  final String id;
  final String userId;
  final String type;
  final String description;
  final double? amount;
  final String? transactionId;
  final String? bankName;
  final String? accountNumber;
  final String? suspectInfo;
  final List<String> evidence;
  final ComplaintStatus status;
  final String? complaintNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Complaint({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    this.amount,
    this.transactionId,
    this.bankName,
    this.accountNumber,
    this.suspectInfo,
    this.evidence = const [],
    this.status = ComplaintStatus.draft,
    this.complaintNumber,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type,
    'description': description,
    'amount': amount,
    'transactionId': transactionId,
    'bankName': bankName,
    'accountNumber': accountNumber,
    'suspectInfo': suspectInfo,
    'evidence': evidence,
    'status': status.index,
    'complaintNumber': complaintNumber,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: json['id'],
    userId: json['userId'],
    type: json['type'],
    description: json['description'],
    amount: json['amount']?.toDouble(),
    transactionId: json['transactionId'],
    bankName: json['bankName'],
    accountNumber: json['accountNumber'],
    suspectInfo: json['suspectInfo'],
    evidence: List<String>.from(json['evidence'] ?? []),
    status: ComplaintStatus.values[json['status'] ?? 0],
    complaintNumber: json['complaintNumber'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt']) 
        : null,
  );
}

enum ComplaintStatus {
  draft,
  submitted,
  underReview,
  resolved,
  rejected,
}