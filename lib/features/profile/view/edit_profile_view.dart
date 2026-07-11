import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/widgets/premium_background.dart';
import '../controller/profile_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController controller = Get.find<ProfileController>();
  late TextEditingController nameController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: controller.userName.value);
    bioController = TextEditingController(text: controller.userBio.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.purpleAccent, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF1E1E1E),
                        backgroundImage: controller.userAvatar.value.isNotEmpty
                            ? NetworkImage(controller.userAvatar.value)
                            : null,
                        child: controller.userAvatar.value.isEmpty
                            ? const Icon(FontAwesomeIcons.user, size: 40, color: Colors.white54)
                            : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF121212), width: 3)),
                      child: const Icon(FontAwesomeIcons.cameraRotate, size: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Name Field
              const Text('Display Name', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(nameController, 'Enter your name', FontAwesomeIcons.userPen),
              const SizedBox(height: 25),

              // Bio Field
              const Text('About Me (Bio)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField(bioController, 'Write something about yourself...', FontAwesomeIcons.addressCard, maxLines: 3),
              const SizedBox(height: 40),

              // Save Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 10,
                    shadowColor: Colors.purpleAccent.withOpacity(0.5),
                  ),
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => controller.updateProfileDetails(nameController.text, bioController.text),
                  child: controller.isProcessing.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController txtController, String hint, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: txtController,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.white54, size: 18) : Padding(
            padding: const EdgeInsets.only(bottom: 45),
            child: Icon(icon, color: Colors.white54, size: 18),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}