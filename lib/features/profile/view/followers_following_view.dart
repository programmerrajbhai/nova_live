import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/widgets/premium_background.dart';
import 'user_profile_view.dart';

class FollowersFollowingView extends StatelessWidget {
  final String userId;
  final String type; // 'followers' or 'following'

  const FollowersFollowingView({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String title = type == 'followers' ? 'Followers' : 'Following';

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // Firebase থেকে subcollection এর ডেটা আনছি
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection(type)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No $type yet.',
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                String targetId = docs[index].id;

                // প্রতিটি ইউজার আইডির জন্য তার নাম এবং ছবি ফেচ করা হচ্ছে
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(targetId).get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const SizedBox.shrink();
                    }

                    var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    String name = userData['name'] ?? 'Nova User';
                    String avatar = userData['avatar'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                          child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.purpleAccent) : null,
                        ),
                        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
                        onTap: () {
                          Get.to(() => UserProfileView(userId: targetId, userName: name, userAvatar: avatar));
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}