import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/widgets/premium_background.dart';
import '../controller/messages_controller.dart';
import 'chat_details_view.dart';

class MessagesView extends StatelessWidget {
  final MessagesController controller = Get.put(MessagesController());

  MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inbox',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Your recent conversations',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.myUid.value.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: controller.getInboxStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildStateView(
                  icon: Icons.error_outline_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Something went wrong!',
                  subtitle: 'Please check your internet connection and try again.',
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFA855F7)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildStateView(
                  icon: Icons.chat_bubble_outline_rounded,
                  iconColor: const Color(0xFF22D3EE),
                  title: 'No messages yet',
                  subtitle: 'Match with someone to start chatting!',
                );
              }

              final docs = snapshot.data!.docs.toList();

              // 🔥 Hybrid Sorting Logic
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                // Time A
                int timeA = 0;
                if (aData['lastUpdated'] is int) {
                  timeA = aData['lastUpdated'];
                } else if (aData['lastUpdated'] is Timestamp) {
                  timeA = (aData['lastUpdated'] as Timestamp).millisecondsSinceEpoch;
                }

                // Time B
                int timeB = 0;
                if (bData['lastUpdated'] is int) {
                  timeB = bData['lastUpdated'];
                } else if (bData['lastUpdated'] is Timestamp) {
                  timeB = (bData['lastUpdated'] as Timestamp).millisecondsSinceEpoch;
                }

                return timeB.compareTo(timeA); // নতুন মেসেজ ১০০% উপরে থাকবে
              });

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final roomData = docs[index].data() as Map<String, dynamic>;
                  final String roomId = docs[index].id;

                  final List<dynamic> participants = roomData['participants'] ?? [];

                  final String targetUid = participants.firstWhere(
                        (id) => id.toString() != controller.myUid.value,
                    orElse: () => '',
                  ).toString();

                  if (targetUid.isEmpty) return const SizedBox.shrink();

                  final Map<String, dynamic> usersData = Map<String, dynamic>.from(roomData['usersData'] ?? {});
                  final Map<String, dynamic> targetData = Map<String, dynamic>.from(
                    usersData[targetUid] ?? {'name': 'Unknown', 'avatar': ''},
                  );

                  final String targetName = targetData['name'] ?? 'User';
                  final String targetAvatar = targetData['avatar'] ?? '';

                  // 🔥 লেটেস্ট মেসেজ ধরবে
                  final String lastMessage = roomData['lastMessage'] ?? 'Started a chat';

                  // 🔥 ডাইনামিক টাইম পাস করা হচ্ছে
                  final dynamic timeData = roomData['lastUpdated'];
                  final String timeAgo = controller.getTimeAgo(timeData);

                  return _buildChatCard(
                    targetName: targetName,
                    targetAvatar: targetAvatar,
                    lastMessage: lastMessage,
                    timeAgo: timeAgo,
                    onTap: () {
                      Get.to(
                            () => ChatDetailsView(
                          roomId: roomId,
                          targetUid: targetUid,
                          targetName: targetName,
                          targetAvatar: targetAvatar,
                        ),
                        transition: Transition.rightToLeftWithFade,
                      );
                    },
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildChatCard({
    required String targetName,
    required String targetAvatar,
    required String lastMessage,
    required String timeAgo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.105),
            Colors.white.withOpacity(0.045),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF22D3EE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF111827),
                        backgroundImage: targetAvatar.isNotEmpty ? NetworkImage(targetAvatar) : null,
                        child: targetAvatar.isEmpty
                            ? const Icon(Icons.person_rounded, color: Colors.white, size: 30)
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 13, height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF070A12), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        targetName,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.1),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastMessage, // 🔥 লেটেস্ট মেসেজটা শো করবে
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeAgo, // 🔥 রিয়েল টাইম শো করবে
                      style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFA855F7), size: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateView({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(colors: [Colors.white.withOpacity(0.105), Colors.white.withOpacity(0.045)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.13), shape: BoxShape.circle, border: Border.all(color: iconColor.withOpacity(0.28))),
                child: Icon(icon, color: iconColor, size: 34),
              ),
              const SizedBox(height: 18),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}