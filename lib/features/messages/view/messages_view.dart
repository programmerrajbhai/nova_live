import 'package:flutter/material.dart';

class MessagesView extends StatelessWidget {
  const MessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Messages', style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Colors.purpleAccent,
            labelColor: Colors.purpleAccent,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Call History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('No new messages', style: TextStyle(color: Colors.grey))),
            Center(child: Text('Your call history is empty', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}