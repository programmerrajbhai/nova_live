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
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
                'Safety & Privacy',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1)
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.purpleAccent]),
                    boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  tabs: const [
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.block_rounded, size: 18), SizedBox(width: 8), Text('Blocked')])),
                    Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.report_problem_rounded, size: 18), SizedBox(width: 8), Text('Reports')])),
                  ],
                ),
              ),
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
      if (controller.myUid.value.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
      }

      return StreamBuilder<QuerySnapshot>(
          stream: controller.getBlockedUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!", style: TextStyle(color: Colors.redAccent)));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(Icons.shield_outlined, "Secure & Clear", "You haven't blocked anyone yet.", Colors.greenAccent);
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String blockedUid = docs[index].id;
                final String blockedName = data['blockedUserName'] ?? 'Unknown User';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.redAccent.withOpacity(0.2),
                      child: const Icon(Icons.person_off_rounded, color: Colors.redAccent, size: 24),
                    ),
                    title: Text(blockedName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('ID: $blockedUid', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white24)),
                      ),
                      onPressed: () => _showConfirmationDialog(
                        title: "Unblock User?",
                        message: "Are you sure you want to unblock $blockedName? They will be able to message you again.",
                        confirmText: "Unblock",
                        confirmColor: Colors.green,
                        onConfirm: () => controller.unblockUser(blockedUid, blockedName),
                      ),
                      child: const Text('Unblock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
      if (controller.myUid.value.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
      }

      return StreamBuilder<QuerySnapshot>(
          stream: controller.getReportedUsers(),
          builder: (context, snapshot) {

            // 🔥 Error Handling
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong!", style: TextStyle(color: Colors.redAccent)));
            }

            // 🔥 Waiting State Check (অসীম লোডিং বন্ধ করার জন্য)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState(Icons.check_circle_outline, "No Active Reports", "You haven't reported anyone recently.", Colors.blueAccent);
            }

            // 🔥 UI থেকে withdrawn রিপোর্টগুলো ফিল্টার করা (ডাটাবেসে ঠিকই থাকবে)
            var activeDocs = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['status'] != 'withdrawn';
            }).toList();

            // 🔥 Local Sorting: নতুন রিপোর্টগুলো উপরে দেখাবে
            activeDocs.sort((a, b) {
              Timestamp? timeA = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
              Timestamp? timeB = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
              if (timeA == null || timeB == null) return 0;
              return timeB.compareTo(timeA); // Descending order
            });

            if (activeDocs.isEmpty) {
              return _buildEmptyState(Icons.check_circle_outline, "No Active Reports", "You haven't reported anyone recently.", Colors.blueAccent);
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              physics: const BouncingScrollPhysics(),
              itemCount: activeDocs.length,
              itemBuilder: (context, index) {
                final data = activeDocs[index].data() as Map<String, dynamic>;
                final String reportId = activeDocs[index].id;
                final String reason = data['reason'] ?? 'Violation of policies';
                final String status = data['status'] ?? 'pending';

                Color statusColor = _getStatusColor(status);
                IconData statusIcon = _getStatusIcon(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 1.5),
                    boxShadow: [BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: statusColor.withOpacity(0.15),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    title: Text(reason, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Status: ${status.toUpperCase()}', style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                    trailing: status == 'pending'
                        ? IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.undo_rounded, color: Colors.orangeAccent, size: 20),
                      ),
                      tooltip: 'Withdraw Report',
                      onPressed: () => _showConfirmationDialog(
                        title: "Withdraw Report?",
                        message: "Are you sure you want to cancel this report?",
                        confirmText: "Withdraw",
                        confirmColor: Colors.orangeAccent,
                        onConfirm: () => controller.undoReport(reportId),
                      ),
                    )
                        : const Icon(Icons.verified_rounded, color: Colors.green, size: 28),
                  ),
                );
              },
            );
          }
      );
    });
  }

  // 🎨 Helper: Status Colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved': return Colors.greenAccent;
      case 'actioned': return Colors.blueAccent;
      case 'rejected': return Colors.redAccent;
      default: return Colors.orangeAccent;
    }
  }

  // 🎨 Helper: Status Icons
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'resolved': return Icons.gavel_rounded;
      case 'actioned': return Icons.shield_rounded;
      case 'rejected': return Icons.cancel_rounded;
      default: return Icons.access_time_filled_rounded;
    }
  }

  // 🖼️ Helper: Beautiful Empty State
  Widget _buildEmptyState(IconData icon, String title, String subtitle, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 40)]),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // 🛑 Helper: Universal Confirmation Dialog
  void _showConfirmationDialog({required String title, required String message, required String confirmText, required Color confirmColor, required VoidCallback onConfirm}) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(color: confirmColor, fontWeight: FontWeight.bold, fontSize: 20),
      middleText: message,
      middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
      backgroundColor: const Color(0xFF1E1E2C),
      radius: 20,
      contentPadding: const EdgeInsets.all(20),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text("Cancel", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        onPressed: onConfirm,
        child: Text(confirmText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}