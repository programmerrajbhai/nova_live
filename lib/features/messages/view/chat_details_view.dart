import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/widgets/premium_background.dart';
import '../controller/messages_controller.dart';

class ChatDetailsView extends StatelessWidget {
  final String roomId;
  final String targetUid;
  final String targetName;
  final String targetAvatar;

  ChatDetailsView({
    super.key,
    required this.roomId,
    required this.targetUid,
    required this.targetName,
    required this.targetAvatar,
  });

  final MessagesController controller = Get.find<MessagesController>();

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.12),
          elevation: 0,
          titleSpacing: 0,
          leadingWidth: 52,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF22D3EE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF111827),
                      backgroundImage: targetAvatar.isNotEmpty ? NetworkImage(targetAvatar) : null,
                      child: targetAvatar.isEmpty ? const Icon(Icons.person_rounded, color: Colors.white, size: 24) : null,
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF070A12), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      targetName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Active now',
                      style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.getChatMessages(roomId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildStateView(icon: Icons.error_outline_rounded, iconColor: Colors.redAccent, title: 'Error loading messages', subtitle: 'Please check your connection and try again.');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildStateView(icon: Icons.waving_hand_rounded, iconColor: const Color(0xFF22D3EE), title: 'Say Hi! 👋', subtitle: 'Start your conversation with a friendly message.');
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final messageData = docs[index].data() as Map<String, dynamic>;
                      final bool isMe = messageData['senderId'] == controller.myUid.value;
                      final String messageText = (messageData['text'] ?? '').toString();

                      if (messageText.trim().isEmpty) return const SizedBox.shrink();

                      return _buildMessageBubble(context: context, text: messageText, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required BuildContext context, required String text, required bool isMe}) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        margin: EdgeInsets.only(left: isMe ? 50 : 0, right: isMe ? 0 : 50, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          gradient: isMe ? const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight) : LinearGradient(colors: [Colors.white.withOpacity(0.115), Colors.white.withOpacity(0.055)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(22), topRight: const Radius.circular(22), bottomLeft: isMe ? const Radius.circular(22) : const Radius.circular(6), bottomRight: isMe ? const Radius.circular(6) : const Radius.circular(22)),
          border: Border.all(color: isMe ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.09)),
          boxShadow: [BoxShadow(color: isMe ? const Color(0xFFA855F7).withOpacity(0.25) : Colors.black.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15.5, height: 1.35, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 6, 14, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [Colors.white.withOpacity(0.115), Colors.white.withOpacity(0.055)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, -6))],
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.08))),
              child: Icon(Icons.emoji_emotions_outlined, color: Colors.white.withOpacity(0.75), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller.messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                minLines: 1, maxLines: 4, textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  controller.sendMessage(roomId, targetUid, targetName, targetAvatar);
                },
                decoration: InputDecoration(hintText: 'Type a message...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 15), filled: true, fillColor: Colors.transparent, contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12), border: InputBorder.none),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                controller.sendMessage(roomId, targetUid, targetName, targetAvatar);
              },
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF22D3EE)], begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFA855F7).withOpacity(0.38), blurRadius: 18, offset: const Offset(0, 7))]),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateView({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: LinearGradient(colors: [Colors.white.withOpacity(0.105), Colors.white.withOpacity(0.045)], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: Colors.white.withOpacity(0.10))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 76, height: 76, decoration: BoxDecoration(color: iconColor.withOpacity(0.13), shape: BoxShape.circle, border: Border.all(color: iconColor.withOpacity(0.28))), child: Icon(icon, color: iconColor, size: 34)),
              const SizedBox(height: 18), Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}