import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/audio_room_controller.dart';

class AudioRoomView extends StatelessWidget {
  final AudioRoomController controller = Get.put(AudioRoomController());

  AudioRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Audio Rooms', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purpleAccent, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: controller.roomList.length,
          itemBuilder: (context, index) {
            final room = controller.roomList[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF141517)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: room.iconColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: room.iconColor.withOpacity(0.15), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5)),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: room.iconColor.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(room.icon, color: room.iconColor, size: 28),
                ),
                title: Text(room.roomName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.headset, color: Colors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text('${room.activeUsers} Listening', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                        child: Text(room.topic, style: TextStyle(color: room.iconColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                onTap: () => controller.joinRoom(room), // পুরো কার্ডে ক্লিক করলেই জয়েন হবে
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}