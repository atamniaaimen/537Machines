import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../common/app_colors.dart';
import '../../widgets/loading_indicator.dart';
import '../../../models/conversation.dart';
import '../../../models/chat_message.dart';
import '../../../core/utils/date_formatter.dart';
import 'messages_viewmodel.dart';

class MessagesView extends StackedView<MessagesViewModel> {
  final String? initialConversationId;

  const MessagesView({this.initialConversationId, super.key});

  @override
  Widget builder(
    BuildContext context,
    MessagesViewModel viewModel,
    Widget? child,
  ) {
    // Chat view when a conversation is selected
    if (viewModel.selectedConversation != null) {
      return _ChatScreen(viewModel: viewModel);
    }

    // Conversation list
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: viewModel.isBusy
                  ? const LoadingIndicator(message: 'Loading conversations...')
                  : viewModel.conversations.isEmpty
                      ? _EmptyState()
                      : RefreshIndicator(
                          onRefresh: viewModel.init,
                          color: AppColors.primaryDark,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: viewModel.conversations.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 88,
                              color: AppColors.gray150,
                            ),
                            itemBuilder: (context, index) {
                              return _ConversationTile(
                                conversation: viewModel.conversations[index],
                                currentUserId: viewModel.currentUserId,
                                onTap: () => viewModel.selectConversation(
                                    viewModel.conversations[index]),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  MessagesViewModel viewModelBuilder(BuildContext context) =>
      MessagesViewModel();

  @override
  void onViewModelReady(MessagesViewModel viewModel) {
    viewModel.initialConversationId = initialConversationId;
    viewModel.init();
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 36,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Messages Yet',
              style: GoogleFonts.titilliumWeb(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you contact a seller or receive a message,\nit will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.titilliumWeb(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.gray400,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Conversation Tile ─────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = conversation.unreadCountFor(currentUserId);
    final hasUnread = unread > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: hasUnread ? AppColors.primaryPale.withOpacity(0.3) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Listing thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray150),
              ),
              clipBehavior: Clip.antiAlias,
              child: conversation.listingImageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: conversation.listingImageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.precision_manufacturing,
                        size: 24,
                        color: AppColors.gray300,
                      ),
                    )
                  : const Icon(
                      Icons.precision_manufacturing,
                      size: 24,
                      color: AppColors.gray300,
                    ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.listingTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage.isNotEmpty
                        ? conversation.lastMessage
                        : 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 13,
                      fontWeight:
                          hasUnread ? FontWeight.w600 : FontWeight.w300,
                      color: hasUnread ? AppColors.dark : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageAt != null)
                  Text(
                    DateFormatter.timeAgo(conversation.lastMessageAt!),
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 11,
                      color: hasUnread ? AppColors.primaryDark : AppColors.gray400,
                      fontWeight:
                          hasUnread ? FontWeight.w600 : FontWeight.w300,
                    ),
                  ),
                if (hasUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread.toString(),
                      style: GoogleFonts.titilliumWeb(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chat Screen ───────────────────────────────────────────────────────────

class _ChatScreen extends StatefulWidget {
  final MessagesViewModel viewModel;

  const _ChatScreen({required this.viewModel});

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  MessagesViewModel get viewModel => widget.viewModel;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    viewModel.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = viewModel.selectedConversation!;

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) viewModel.backToList();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Chat header
              Container(
                color: AppColors.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: viewModel.backToList,
                      child: const Icon(Icons.arrow_back,
                          size: 22, color: AppColors.gray500),
                    ),
                    const SizedBox(width: 12),
                    // Listing thumbnail
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: conversation.listingImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: conversation.listingImageUrl,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.precision_manufacturing,
                              size: 20, color: AppColors.gray300),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conversation.listingTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                          Text(
                            '${_formatPrice(conversation.listingPrice)} DZD',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.gray150),

              // Messages
              Expanded(
                child: viewModel.loadingMessages
                    ? const LoadingIndicator(message: 'Loading messages...')
                    : viewModel.messages.isEmpty
                        ? _chatEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            itemCount: viewModel.messages.length,
                            itemBuilder: (context, index) {
                              return _MessageBubble(
                                message: viewModel.messages[index],
                                isMe: viewModel.messages[index].senderId ==
                                    viewModel.currentUserId,
                                showTimestamp: _shouldShowTimestamp(index),
                              );
                            },
                          ),
              ),

              // Quick reply chips
              if (viewModel.messages.isEmpty)
                _quickReplies(),

              // Input bar
              _inputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_outlined,
                size: 48, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: GoogleFonts.titilliumWeb(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Send a message about this listing',
              style: GoogleFonts.titilliumWeb(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickReplies() {
    final replies = [
      'Is this still available?',
      'What\'s the lowest price?',
      'Can I see it in person?',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: replies.map((text) {
          return GestureDetector(
            onTap: () {
              _textController.text = text;
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Text(
                text,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.gray200),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                style: GoogleFonts.titilliumWeb(
                  fontSize: 14,
                  color: AppColors.dark,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.titilliumWeb(
                    fontSize: 14,
                    color: AppColors.gray300,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.send,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    final current = viewModel.messages[index].createdAt;
    final previous = viewModel.messages[index - 1].createdAt;
    return current.difference(previous).inMinutes > 15;
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);
      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        buffer.write(formatted[i]);
        count++;
        if (count % 3 == 0 && i != 0) buffer.write(',');
      }
      return buffer.toString().split('').reversed.join();
    }
    return price.toStringAsFixed(0);
  }
}

// ─── Message Bubble ────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTimestamp;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                _formatTimestamp(message.createdAt),
                style: GoogleFonts.titilliumWeb(
                  fontSize: 11,
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
        Container(
          margin: EdgeInsets.only(
            bottom: 4,
            left: isMe ? 60 : 0,
            right: isMe ? 0 : 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryDark : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 18),
            ),
            border: isMe ? null : Border.all(color: AppColors.gray150),
          ),
          child: Text(
            message.text,
            style: GoogleFonts.titilliumWeb(
              fontSize: 14,
              color: isMe ? Colors.white : AppColors.dark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inDays == 0) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }
}
