import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/messages_controller.dart';
import 'chat_details_view.dart';

class MessagesView extends StatelessWidget {
  final MessagesController controller = Get.put(MessagesController());

  MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Inbox', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.myUid.value.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
        }

        return StreamBuilder<QuerySnapshot>(
          stream: controller.getInboxStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong!', style: TextStyle(color: Colors.red)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No messages yet.\nMatch with someone to start chatting!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              );
            }

            // 🔥 লোকাল সর্টিং (নতুন মেসেজ সবার উপরে থাকবে)
            var docs = snapshot.data!.docs;
            docs.sort((a, b) {
              var aData = a.data() as Map<String, dynamic>;
              var bData = b.data() as Map<String, dynamic>;
              Timestamp? timeA = aData['lastUpdated'];
              Timestamp? timeB = bData['lastUpdated'];
              if (timeA == null) return 1;
              if (timeB == null) return -1;
              return timeB.compareTo(timeA);
            });

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var roomData = docs[index].data() as Map<String, dynamic>;
                String roomId = docs[index].id;

                List<dynamic> participants = roomData['participants'] ?? [];
                String targetUid = participants.firstWhere((id) => id != controller.myUid.value, orElse: () => '');

                if (targetUid.isEmpty) return const SizedBox();

                Map<String, dynamic> usersData = roomData['usersData'] ?? {};
                Map<String, dynamic> targetData = usersData[targetUid] ?? {'name': 'Unknown', 'avatar': ''};

                String targetName = targetData['name'] ?? 'User';
                String targetAvatar = targetData['avatar'] ?? '';
                String lastMessage = roomData['lastMessage'] ?? 'Started a chat';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white10,
                      backgroundImage: targetAvatar.isNotEmpty ? NetworkImage(targetAvatar) : null,
                      child: targetAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    title: Text(targetName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    onTap: () {
                      Get.to(() => ChatDetailsView(
                        roomId: roomId,
                        targetUid: targetUid,
                        targetName: targetName,
                        targetAvatar: targetAvatar,
                      ));
                    },
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}