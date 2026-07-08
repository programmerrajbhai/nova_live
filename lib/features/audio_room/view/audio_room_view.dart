import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/audio_room_controller.dart';
import '../model/audio_room_model.dart';

class AudioRoomView extends StatelessWidget {
  final AudioRoomController controller = Get.put(AudioRoomController());
  final TextEditingController roomNameController = TextEditingController();

  AudioRoomView({super.key});

  void _showCreateRoomDialog(BuildContext context) {
    roomNameController.clear();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Start Live Audio Room', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: roomNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "E.g. Midnight Chill Adda 🎵",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF16213E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Get.back();
              controller.startMyRoom(roomNameController.text.trim());
            },
            child: const Text('Go Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F3460),
      appBar: AppBar(
        title: const Text('Nova Audio Rooms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: Obx(() => ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 10,
                shadowColor: const Color(0xFFE94560).withOpacity(0.5),
              ),
              onPressed: controller.isCreatingRoom.value ? null : () => _showCreateRoomDialog(context),
              icon: controller.isCreatingRoom.value ? const SizedBox() : const Icon(Icons.mic, color: Colors.white, size: 28),
              label: controller.isCreatingRoom.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create My Room', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            )),
          ),

          const SizedBox(height: 15),
          Expanded(
            child: StreamBuilder<List<AudioRoomModel>>(
              stream: controller.getLiveRoomsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFE94560)));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No active rooms right now.\nBe the first to create one!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 16)));

                var rooms = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    AudioRoomModel room = rooms[index];

                    return GestureDetector(
                      // 🔥 FIX: জয়েন করার সময় হোস্টের ছবি (hostAvatar) লোগো হিসেবে পাঠিয়ে দেওয়া হলো
                      onTap: () => controller.joinRoom(room.roomId, room.roomName, room.hostAvatar),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white10,
                              backgroundImage: room.hostAvatar.isNotEmpty ? NetworkImage(room.hostAvatar) : null,
                              child: room.hostAvatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(room.roomName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 5),
                                  Text('Host: ${room.hostName}', style: const TextStyle(color: Colors.white54, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const Icon(Icons.waves, color: Color(0xFFE94560), size: 30),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}