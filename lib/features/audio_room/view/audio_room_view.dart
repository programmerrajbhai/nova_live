import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova_live/core/widgets/premium_background.dart';

import '../controller/audio_room_controller.dart';
import '../model/audio_room_model.dart';

class AudioRoomView extends StatelessWidget {
  final AudioRoomController controller = Get.put(AudioRoomController());
  final TextEditingController roomNameController = TextEditingController();

  AudioRoomView({super.key});

  static const bg = Color(0xFF170815);
  static const pink = Color(0xFFFF5DAE);
  static const hotPink = Color(0xFFE948A0);
  static const purple = Color(0xFF8A35FF);

  void _showCreateRoomDialog(BuildContext context) {
    roomNameController.clear();
    controller.pickedLogo = null;
    controller.pickedLogoPath.value = '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: GlassBox(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Start Live Audio Room',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),

              Obx(() {
                final path = controller.pickedLogoPath.value;

                return GestureDetector(
                  onTap: controller.pickRoomLogo,
                  child: Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [pink, hotPink, purple]),
                    ),
                    child: CircleAvatar(
                      backgroundColor: bg,
                      backgroundImage: path.isNotEmpty ? FileImage(File(path)) : null,
                      child: path.isEmpty
                          ? const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 34)
                          : null,
                    ),
                  ),
                );
              }),

              const SizedBox(height: 10),

              Text(
                'Tap to choose room logo',
                style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 12),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: roomNameController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                cursorColor: pink,
                decoration: InputDecoration(
                  hintText: "E.g. Midnight Chill Adda 🎵",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.30)),
                  prefixIcon: const Icon(Icons.graphic_eq_rounded, color: pink),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: PremiumButton(
                      title: 'Cancel',
                      isPrimary: false,
                      onTap: () => Get.back(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PremiumButton(
                      title: 'Go Live',
                      onTap: () {
                        Get.back();
                        controller.startMyRoom(roomNameController.text.trim());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.65),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: PremiumBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  const CircleGradientIcon(icon: Icons.graphic_eq_rounded),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Nova Audio Rooms',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.waves_rounded, color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
              child: GlassBox(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create your own room',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start a live audio room with your custom name and logo.',
                      style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 13.5),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => PremiumButton(
                      title: controller.isCreatingRoom.value ? 'Creating...' : 'Create My Room',
                      icon: controller.isCreatingRoom.value ? null : Icons.mic_rounded,
                      onTap: controller.isCreatingRoom.value ? null : () => _showCreateRoomDialog(context),
                    )),
                  ],
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<List<AudioRoomModel>>(
                stream: controller.getLiveRoomsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: pink));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return EmptyRooms(onCreate: () => _showCreateRoomDialog(context));
                  }

                  final rooms = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
                    itemCount: rooms.length,
                    itemBuilder: (_, index) => RoomCard(
                      room: rooms[index],
                      onTap: () => controller.joinRoom(
                        rooms[index].roomId,
                        rooms[index].roomName,
                        rooms[index].roomLogo,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final AudioRoomModel room;
  final VoidCallback onTap;

  const RoomCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassBox(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatarPremium(image: room.roomLogo),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Host: ${room.hostName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.48), fontSize: 13),
                  ),
                  const SizedBox(height: 9),
                  const Row(
                    children: [
                      SmallTag(icon: Icons.mic_rounded, text: 'Audio'),
                      SizedBox(width: 8),
                      SmallTag(icon: Icons.radio_button_checked_rounded, text: 'LIVE'),
                    ],
                  ),
                ],
              ),
            ),
            const CircleGradientIcon(icon: Icons.arrow_forward_rounded, size: 42),
          ],
        ),
      ),
    );
  }
}

class EmptyRooms extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyRooms({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassBox(
        margin: const EdgeInsets.all(26),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleGradientIcon(icon: Icons.meeting_room_rounded, size: 70),
            const SizedBox(height: 16),
            const Text(
              'No active rooms right now',
              style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to create a live audio room.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 13.5),
            ),
            const SizedBox(height: 18),
            PremiumButton(title: 'Create Room', onTap: onCreate),
          ],
        ),
      ),
    );
  }
}

class GlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  const GlassBox({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AudioRoomView.bg.withOpacity(0.68),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 12)),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PremiumButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isPrimary;

  const PremiumButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isPrimary
                ? const LinearGradient(colors: [AudioRoomView.hotPink, AudioRoomView.purple])
                : null,
            color: isPrimary ? null : Colors.white.withOpacity(0.07),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(isPrimary ? 1 : 0.65),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleGradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const CircleGradientIcon({
    super.key,
    required this.icon,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AudioRoomView.pink, AudioRoomView.hotPink, AudioRoomView.purple]),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.52),
    );
  }
}

class CircleAvatarPremium extends StatelessWidget {
  final String image;

  const CircleAvatarPremium({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AudioRoomView.pink, AudioRoomView.hotPink, AudioRoomView.purple]),
      ),
      child: CircleAvatar(
        backgroundColor: AudioRoomView.bg,
        backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
        child: image.isEmpty ? const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 30) : null,
      ),
    );
  }
}

class SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const SmallTag({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Icon(icon, color: AudioRoomView.pink, size: 13),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}