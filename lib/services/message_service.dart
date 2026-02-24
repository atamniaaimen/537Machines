import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../app/app.locator.dart';
import '../core/error_handling/executor.dart';
import '../core/services/crashlytics_service.dart';
import '../core/constants/firebase_constants.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import '../repositories/firestore_repository.dart';

class MessageService {
  final _firestoreRepo = locator<FirestoreRepository>();
  final _crashlytics = locator<CrashlyticsService>();

  Future<List<Conversation>> getConversations(String userId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection: FirebaseConstants.conversationsCollection,
      queryBuilder: (ref) => ref
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageAt', descending: true),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'MessageService',
                  'getConversations($userId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs
              .map((d) => Conversation.fromJson(d, id: d['id']))
              .toList(),
        ));
  }

  Future<List<ChatMessage>> getMessages(String conversationId) {
    return Executor.run(_firestoreRepo.getCollection(
      collection:
          '${FirebaseConstants.conversationsCollection}/$conversationId/messages',
      queryBuilder: (ref) => ref.orderBy('createdAt', descending: false),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'MessageService',
                  'getMessages($conversationId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docs) => docs
              .map((d) => ChatMessage.fromJson(d, id: d['id']))
              .toList(),
        ));
  }

  Future<void> sendMessage(String conversationId, ChatMessage message) {
    return Executor.run(_firestoreRepo.addDocument(
      collection:
          '${FirebaseConstants.conversationsCollection}/$conversationId/messages',
      data: message.toJson(),
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'MessageService',
                  'sendMessage($conversationId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) async {
            // Update conversation's lastMessage and increment unread for receiver
            await Executor.run(_firestoreRepo.setDocument(
              collection: FirebaseConstants.conversationsCollection,
              id: conversationId,
              data: {
                'lastMessage': message.text,
                'lastMessageAt': Timestamp.fromDate(message.createdAt),
              },
              merge: true,
            )).then((result) => result.fold(
                  (failure) {
                    _crashlytics.logToCrashlytics(
                        Level.warning,
                        [
                          'MessageService',
                          'sendMessage(updateConversation)',
                          failure.toString()
                        ],
                        failure.stackTrace);
                  },
                  (_) {},
                ));
          },
        ));
  }

  Future<Conversation> getOrCreateConversation({
    required String senderId,
    required String receiverId,
    required String listingId,
    required String listingTitle,
    required double listingPrice,
    required String listingImageUrl,
  }) async {
    // Find existing conversation between these users for this listing
    final result = await Executor.run(_firestoreRepo.getCollection(
      collection: FirebaseConstants.conversationsCollection,
      queryBuilder: (ref) => ref
          .where('participantIds', arrayContains: senderId)
          .where('listingId', isEqualTo: listingId),
    ));

    return result.fold(
      (failure) {
        _crashlytics.logToCrashlytics(
            Level.warning,
            [
              'MessageService',
              'getOrCreateConversation(query)',
              failure.toString()
            ],
            failure.stackTrace);
        throw failure;
      },
      (docs) async {
        // Check if any conversation has the receiver as a participant
        for (final doc in docs) {
          final conv = Conversation.fromJson(doc, id: doc['id']);
          if (conv.participantIds.contains(receiverId)) {
            return conv;
          }
        }

        // Create new conversation
        final conversation = Conversation(
          id: '',
          participantIds: [senderId, receiverId],
          listingId: listingId,
          listingTitle: listingTitle,
          listingPrice: listingPrice,
          listingImageUrl: listingImageUrl,
          lastMessage: '',
          lastMessageAt: DateTime.now(),
          unreadCounts: {senderId: 0, receiverId: 0},
        );

        final createResult = await Executor.run(_firestoreRepo.addDocument(
          collection: FirebaseConstants.conversationsCollection,
          data: conversation.toJson(),
        ));

        return createResult.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'MessageService',
                  'getOrCreateConversation(create)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (docId) => Conversation(
            id: docId,
            participantIds: conversation.participantIds,
            listingId: conversation.listingId,
            listingTitle: conversation.listingTitle,
            listingPrice: conversation.listingPrice,
            listingImageUrl: conversation.listingImageUrl,
            lastMessage: conversation.lastMessage,
            lastMessageAt: conversation.lastMessageAt,
            unreadCounts: conversation.unreadCounts,
          ),
        );
      },
    );
  }

  Future<void> markConversationRead(
      String conversationId, String userId) {
    return Executor.run(_firestoreRepo.setDocument(
      collection: FirebaseConstants.conversationsCollection,
      id: conversationId,
      data: {
        'unreadCounts.$userId': 0,
      },
      merge: true,
    )).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                [
                  'MessageService',
                  'markConversationRead($conversationId)',
                  failure.toString()
                ],
                failure.stackTrace);
            throw failure;
          },
          (_) {},
        ));
  }
}
