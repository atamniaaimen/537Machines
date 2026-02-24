import 'package:cloud_firestore/cloud_firestore.dart';

class Offer {
  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;

  const Offer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    this.status = 'pending',
    required this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json, {String? id}) {
    return Offer(
      id: id ?? json['id'] ?? '',
      listingId: json['listingId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listingId': listingId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'amount': amount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Offer copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    String? sellerId,
    double? amount,
    String? status,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
