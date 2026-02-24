import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final String listingId;
  final String listingTitle;
  final double listingPrice;
  final String listingImageUrl;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;

  const Conversation({
    required this.id,
    required this.participantIds,
    required this.listingId,
    this.listingTitle = '',
    this.listingPrice = 0,
    this.listingImageUrl = '',
    this.lastMessage = '',
    this.lastMessageAt,
    this.unreadCounts = const {},
  });

  factory Conversation.fromJson(Map<String, dynamic> json, {String? id}) {
    return Conversation(
      id: id ?? json['id'] ?? '',
      participantIds: List<String>.from(json['participantIds'] ?? []),
      listingId: json['listingId'] ?? '',
      listingTitle: json['listingTitle'] ?? '',
      listingPrice: (json['listingPrice'] ?? 0).toDouble(),
      listingImageUrl: json['listingImageUrl'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: json['lastMessageAt'] is Timestamp
          ? (json['lastMessageAt'] as Timestamp).toDate()
          : null,
      unreadCounts: Map<String, int>.from(json['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantIds': participantIds,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingPrice': listingPrice,
      'listingImageUrl': listingImageUrl,
      'lastMessage': lastMessage,
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'unreadCounts': unreadCounts,
    };
  }

  int unreadCountFor(String userId) => unreadCounts[userId] ?? 0;
}
