import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String company;
  final String phone;
  final String location;
  final String bio;
  final bool notifyMessages;
  final bool notifyOffers;
  final bool notifyPriceDrops;
  final bool notifyNewListings;
  final String role; // 'buyer', 'seller', 'both'
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoUrl = '',
    this.company = '',
    this.phone = '',
    this.location = '',
    this.bio = '',
    this.notifyMessages = true,
    this.notifyOffers = true,
    this.notifyPriceDrops = false,
    this.notifyNewListings = false,
    this.role = 'both',
    required this.createdAt,
  });

  String get displayName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (f.isEmpty && l.isEmpty) return '?';
    return '$f$l';
  }

  factory AppUser.fromJson(Map<String, dynamic> json, {String? id}) {
    final display = json['displayName'] ?? '';
    final parts = display.toString().split(' ');
    return AppUser(
      uid: id ?? json['uid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? (parts.isNotEmpty ? parts.first : ''),
      lastName: json['lastName'] ??
          (parts.length > 1 ? parts.sublist(1).join(' ') : ''),
      photoUrl: json['photoUrl'] ?? '',
      company: json['company'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      notifyMessages: json['notifyMessages'] ?? true,
      notifyOffers: json['notifyOffers'] ?? true,
      notifyPriceDrops: json['notifyPriceDrops'] ?? false,
      notifyNewListings: json['notifyNewListings'] ?? false,
      role: json['role'] ?? 'both',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'company': company,
      'phone': phone,
      'location': location,
      'bio': bio,
      'notifyMessages': notifyMessages,
      'notifyOffers': notifyOffers,
      'notifyPriceDrops': notifyPriceDrops,
      'notifyNewListings': notifyNewListings,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? company,
    String? phone,
    String? location,
    String? bio,
    bool? notifyMessages,
    bool? notifyOffers,
    bool? notifyPriceDrops,
    bool? notifyNewListings,
    String? role,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      notifyMessages: notifyMessages ?? this.notifyMessages,
      notifyOffers: notifyOffers ?? this.notifyOffers,
      notifyPriceDrops: notifyPriceDrops ?? this.notifyPriceDrops,
      notifyNewListings: notifyNewListings ?? this.notifyNewListings,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
