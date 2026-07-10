import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/premium_background.dart';
import '../controller/settings_controller.dart';

class SettingsView extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.2),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Safety Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            bottom: const TabBar(
              indicatorColor: Colors.pinkAccent,
              labelColor: Colors.pinkAccent,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(icon: Icon(Icons.block_rounded), text: 'Blocked Users'),
                Tab(icon: Icon(Icons.report_problem_rounded), text: 'My Reports'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildBlockedTab(),
              _buildReportsTab(),
            ],
          ),
        ),
      ),
    );
  }

  // 🚫 Blocked Users Tab
  Widget _buildBlockedTab() {
    return Obx(() {
      if (controller.myUid.value.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));

      return StreamBuilder<QuerySnapshot>(
          stream: controller.getBlockedUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No blocked users.", style: TextStyle(color: Colors.white54, fontSize: 16)));
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String blockedUid = data['blockedUserId'] ?? '';
                final String blockedName = data['blockedUserName'] ?? 'Unknown User';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.2), child: const Icon(Icons.person_off, color: Colors.redAccent)),
                    title: Text(blockedName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: $blockedUid', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      onPressed: () => controller.unblockUser(blockedUid, blockedName),
                      child: const Text('Unblock', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                );
              },
            );
          }
      );
    });
  }

  // 🚩 Reported Users Tab
  Widget _buildReportsTab() {
    return Obx(() {
      if (controller.myUid.value.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));

      return StreamBuilder<QuerySnapshot>(
          stream: controller.getReportedUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("You haven't reported anyone.", style: TextStyle(color: Colors.white54, fontSize: 16)));
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String reportId = docs[index].id;
                final String reason = data['reason'] ?? 'Violation of policies';
                final String status = data['status'] ?? 'Pending';

                Color statusColor = status == 'resolved' ? Colors.green : Colors.orangeAccent;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.orangeAccent.withOpacity(0.2), child: const Icon(Icons.report, color: Colors.orangeAccent)),
                    title: Text(reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('Status: ${status.capitalizeFirst}', style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    trailing: status == 'pending' ? IconButton(
                      icon: const Icon(Icons.undo_rounded, color: Colors.white54),
                      tooltip: 'Undo Report',
                      onPressed: () => controller.undoReport(reportId),
                    ) : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            );
          }
      );
    });
  }
}