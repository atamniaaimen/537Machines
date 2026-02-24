import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import '../../../app/app.locator.dart';
import '../../../core/error_handling/executor.dart';
import '../../../core/services/crashlytics_service.dart';
import '../../../models/conversation.dart';
import '../../../models/chat_message.dart';
import '../../../services/message_service.dart';
import '../../../services/auth_service.dart';

class MessagesViewModel extends BaseViewModel {
  final _messageService = locator<MessageService>();
  final _authService = locator<AuthService>();
  final _crashlytics = locator<CrashlyticsService>();

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  Conversation? _selectedConversation;
  Conversation? get selectedConversation => _selectedConversation;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _loadingMessages = false;
  bool get loadingMessages => _loadingMessages;

  String get currentUserId => _authService.currentUser?.uid ?? '';

  /// Optional: pre-select a conversation (e.g. from Contact Seller)
  String? initialConversationId;

  Future<void> init() async {
    setBusy(true);

    return Executor.run(_messageService.getConversations(currentUserId))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    ['MessagesViewModel', 'init()', failure.toString()],
                    failure.stackTrace);
                setError(failure);
                setBusy(false);
              },
              (data) {
                _conversations = data;
                setBusy(false);

                // Auto-select if an initial conversation was passed
                if (initialConversationId != null) {
                  final match = _conversations
                      .where((c) => c.id == initialConversationId)
                      .toList();
                  if (match.isNotEmpty) {
                    selectConversation(match.first);
                  }
                  initialConversationId = null;
                }

                rebuildUi();
              },
            ));
  }

  Future<void> selectConversation(Conversation conversation) async {
    _selectedConversation = conversation;
    _loadingMessages = true;
    rebuildUi();

    // Mark as read (silent fail)
    Executor.run(
      _messageService.markConversationRead(conversation.id, currentUserId),
    );

    return Executor.run(_messageService.getMessages(conversation.id))
        .then((result) => result.fold(
              (failure) {
                _crashlytics.logToCrashlytics(
                    Level.warning,
                    [
                      'MessagesViewModel',
                      'selectConversation()',
                      failure.toString()
                    ],
                    failure.stackTrace);
                _loadingMessages = false;
                setError('Could not load messages');
                rebuildUi();
              },
              (data) {
                _messages = data;
                _loadingMessages = false;
                rebuildUi();
              },
            ));
  }

  void backToList() {
    _selectedConversation = null;
    _messages = [];
    rebuildUi();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _selectedConversation == null) return;

    final message = ChatMessage(
      id: '',
      senderId: currentUserId,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    // Optimistic update
    _messages = [..._messages, message];
    rebuildUi();

    return Executor.run(
      _messageService.sendMessage(_selectedConversation!.id, message),
    ).then((result) => result.fold(
          (failure) {
            _crashlytics.logToCrashlytics(
                Level.warning,
                ['MessagesViewModel', 'sendMessage()', failure.toString()],
                failure.stackTrace);
            setError('Failed to send message');
          },
          (_) {},
        ));
  }

  /// Returns the other participant's ID for display purposes
  String otherParticipantId(Conversation conv) {
    return conv.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
