import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controller/wallet_controller.dart';
import '../../../core/widgets/premium_background.dart';

class WalletView extends StatelessWidget {
  WalletView({super.key});

  final WalletController walletCtrl = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('My Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏆 Balance Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF311B92)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(FontAwesomeIcons.coins, color: Colors.amber, size: 40),
                          const SizedBox(width: 15),
                          Text('${walletCtrl.myCoins.value}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Text('Earn Free Tokens', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // 🎁 1. Daily Check-in Card
                _buildActionCard(
                  title: 'Daily Check-in',
                  subtitle: walletCtrl.canClaimDaily.value ? 'Claim your 30 free coins now!' : 'Come back tomorrow',
                  icon: FontAwesomeIcons.calendarCheck,
                  iconColor: Colors.greenAccent,
                  buttonText: walletCtrl.canClaimDaily.value ? 'Claim' : 'Claimed',
                  buttonColor: walletCtrl.canClaimDaily.value ? Colors.green : Colors.grey.withOpacity(0.5),
                  onTap: walletCtrl.canClaimDaily.value ? () => walletCtrl.claimDailyReward() : null,
                  isLoading: walletCtrl.isProcessing.value && walletCtrl.canClaimDaily.value,
                ),

                const SizedBox(height: 15),

                // 📺 2. Watch Ad Card
                _buildActionCard(
                  title: 'Watch Video Ad',
                  subtitle: 'Earn 50 coins instantly',
                  icon: FontAwesomeIcons.circlePlay,
                  iconColor: Colors.pinkAccent,
                  buttonText: walletCtrl.isAdLoading.value ? 'Loading' : 'Watch',
                  buttonColor: walletCtrl.isAdLoaded.value ? Colors.pinkAccent : Colors.grey.withOpacity(0.5),
                  onTap: walletCtrl.isAdLoaded.value ? () => walletCtrl.showRewardedAd() : null,
                  isLoading: walletCtrl.isAdLoading.value,
                ),

                const SizedBox(height: 40),
                const Text('Store', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // 🛒 3. Top Up Card
                _buildActionCard(
                  title: 'Top Up Coins',
                  subtitle: 'Buy via Google Play / Card',
                  icon: FontAwesomeIcons.cartShopping,
                  iconColor: Colors.cyanAccent,
                  buttonText: 'Buy',
                  buttonColor: Colors.cyan,
                  onTap: () {
                    Get.snackbar('Coming Soon', 'Store integration is in progress.', colorText: Colors.white, backgroundColor: Colors.purple);
                  },
                  isLoading: false,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color iconColor, required String buttonText, required Color buttonColor, required VoidCallback? onTap, required bool isLoading}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: iconColor.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ]),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            onPressed: onTap,
            child: isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}