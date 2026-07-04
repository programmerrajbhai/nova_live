import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/matching_controller.dart';

class MatchingView extends StatelessWidget {
  final MatchingController controller = Get.put(MatchingController());

  MatchingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Live', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.tune, color: Colors.white),
            onSelected: controller.setFilter,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Global', child: ListTile(leading: Icon(Icons.public, color: Colors.blue), title: Text('Global Match'))),
              const PopupMenuItem(value: 'Local', child: ListTile(leading: Icon(Icons.location_on, color: Colors.red), title: Text('Local Match'))),
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('Filter: ${controller.selectedFilter.value}', style: const TextStyle(color: Colors.grey, fontSize: 16))),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: controller.toggleSearch,
              child: Obx(() => Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurple]),
                  boxShadow: controller.isSearching.value
                      ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.8), blurRadius: 40, spreadRadius: 20)]
                      : [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Center(
                  child: Text(
                    controller.isSearching.value ? 'Searching...' : 'Tap to\nMatch',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}