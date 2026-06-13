import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/network/socket/socket_events.dart';
import '../../../../core/network/socket/socket_manager.dart';
import '../../../../presentation/widgets/app_app_bar.dart';

class _ChatMessage {
  final String id, senderId, senderName, text;
  final DateTime time;
  final bool isMe;
  _ChatMessage({required this.id, required this.senderId, required this.senderName, required this.text, required this.time, required this.isMe});
}

class TeamChatScreen extends StatefulWidget {
  final String roomId, roomName;
  const TeamChatScreen({super.key, required this.roomId, required this.roomName});
  @override State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  String _myId = '';
  String _myName = '';
  bool _otherTyping = false;
  String _typingName = '';
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final prefs = getIt<SharedPreferences>();
    _myId = prefs.getString('user_id') ?? '';
    _myName = '${prefs.getString('first_name') ?? ''} ${prefs.getString('last_name') ?? ''}'.trim();
    final token = prefs.getString('auth_token') ?? '';
    if (token.isNotEmpty) SocketManager.instance.connectAll(token);
    final socket = SocketManager.instance.chatSocket;
    socket.emit(SocketEvents.joinRoom, {'roomId': widget.roomId});
    socket.on(SocketEvents.receiveMessage, _onMessage);
    socket.on(SocketEvents.userTyping, _onTyping);
  }

  void _onMessage(dynamic data) {
    if (data is Map) {
      setState(() {
        _messages.add(_ChatMessage(
          id: data['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: data['senderId']?.toString() ?? '',
          senderName: data['senderName']?.toString() ?? 'Unknown',
          text: data['text']?.toString() ?? '',
          time: data['createdAt'] != null ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now() : DateTime.now(),
          isMe: data['senderId']?.toString() == _myId,
        ));
      });
      _scrollToBottom();
    }
  }

  void _onTyping(dynamic data) {
    if (data is Map && data['userId'] != _myId) {
      setState(() { _otherTyping = true; _typingName = data['userName']?.toString() ?? ''; });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _otherTyping = false);
      });
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    SocketManager.instance.chatSocket.emit(SocketEvents.sendMessage, {
      'roomId': widget.roomId, 'text': text, 'senderId': _myId, 'senderName': _myName,
    });
    setState(() {
      _messages.add(_ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: _myId, senderName: _myName, text: text,
        time: DateTime.now(), isMe: true,
      ));
    });
    _scrollToBottom();
  }

  void _onTypingInput(String _) {
    SocketManager.instance.chatSocket.emit(SocketEvents.userTyping, {
      'roomId': widget.roomId, 'userId': _myId, 'userName': _myName,
    });
    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    SocketManager.instance.chatSocket.off(SocketEvents.receiveMessage);
    SocketManager.instance.chatSocket.off(SocketEvents.userTyping);
    SocketManager.instance.chatSocket.emit(SocketEvents.leaveRoom, {'roomId': widget.roomId});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(title: widget.roomName, showBack: true),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat_bubble_outline, size: 56.sp, color: AppColors.border),
                    SizedBox(height: 12.h),
                    Text('No messages yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    SizedBox(height: 4.h),
                    Text('Say hi to your team!', style: AppTextStyles.caption),
                  ]))
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
                  ),
          ),
          if (_otherTyping)
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('$_typingName is typing...', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
              ),
            ),
          _InputBar(controller: _controller, onSend: _sendMessage, onChanged: _onTypingInput),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage msg;
  const _MessageBubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        if (!isMe)
          Padding(
            padding: EdgeInsets.only(left: 8.w, bottom: 2.h),
            child: Text(msg.senderName, style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
              ),
              SizedBox(width: 6.w),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                    bottomRight: Radius.circular(isMe ? 4.r : 16.r),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                ),
                child: Text(msg.text,
                    style: AppTextStyles.bodySmall.copyWith(color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary)),
              ),
            ),
            if (isMe) ...[
              SizedBox(width: 4.w),
              Icon(Icons.done_all, size: 14.sp, color: AppColors.success),
            ],
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 2.h, left: isMe ? 0 : 44.w, right: isMe ? 20.w : 0,
          ),
          child: Text(
            '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.caption,
          ),
        ),
      ]),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final void Function(String) onChanged;
  const _InputBar({required this.controller, required this.onSend, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom + 8.h,
      ),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                minLines: 1, maxLines: 4,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: onSend,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ]),
      ),
    );
  }
}
