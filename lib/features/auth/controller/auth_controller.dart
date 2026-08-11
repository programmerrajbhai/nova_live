import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../main_nav/view/main_nav_view.dart';
import '../../splash/banned_view.dart'; // 🔥 Import BannedView

class AuthController extends GetxController {
  final nameController = TextEditingController();
  var isAgreed = false.obs;
  var isLoading = false.obs;
  var selectedGender = 'Male'.obs;
  var dobString = ''.obs;
  var calculatedAge = 0.obs;
  var ageVerified = false.obs;

  static const String currentPolicyVersion = "1.0";

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  var selectedLocalImagePath = ''.obs;

  final List<String> defaultAvatars = [
    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
    'https://cdn-icons-png.flaticon.com/512/3135/3135789.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140048.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140037.png',
    'https://cdn-icons-png.flaticon.com/512/4140/4140047.png',
  ];
  var selectedAvatar = ''.obs;

  void toggleAgreement(bool? value) {
    isAgreed.value = value ?? false;
  }

  Future<void> onOneTapLoginClicked() async {
    if (!isAgreed.value) {
      _showAgreementWarning();
      return;
    }

    isLoading.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      User? authUser = FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        final UserCredential credential = await FirebaseAuth.instance.signInAnonymously();
        authUser = credential.user;
      }

      if (authUser == null) {
        throw FirebaseAuthException(
          code: 'anonymous-sign-in-failed',
          message: 'Unable to create an anonymous Nova Live session.',
        );
      }

      final String currentUid = authUser.uid;
      await prefs.setString('device_linked_uid', currentUid);

      final DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection('users').doc(currentUid);
      final DocumentSnapshot<Map<String, dynamic>> doc = await userRef.get();

      if (doc.exists) {
        final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};

        // 🔥 FIX 24: Banned User Login Bypass Check
        bool isBanned = data['isBanned'] == true;
        Timestamp? bannedUntil = data['bannedUntil'] as Timestamp?;

        if (isBanned) {
          if (bannedUntil == null || bannedUntil.toDate().isAfter(DateTime.now())) {
            isLoading.value = false;
            String banReason = data['banReason'] ?? 'Violation of Terms & Policies';
            String banType = data['banType'] ?? 'Account Suspension'; // 🔥 Fixed Missing Arguments

            Get.offAll(() => BannedView(banReason: banReason, banType: banType));
            return; // 🛑 ব্যানড ইউজার হলে আর সামনে এগোবে না
          }
        }

        final bool verified = data['ageVerified'] == true;
        final String dob = (data['dob'] ?? '').toString().trim();

        if (!verified || dob.isEmpty) {
          isLoading.value = false;
          nameController.text = (data['name'] ?? '').toString();
          selectedGender.value = (data['gender'] ?? 'Male').toString();
          final String savedAvatar = (data['avatar'] ?? '').toString();
          selectedAvatar.value = savedAvatar.isNotEmpty ? savedAvatar : defaultAvatars.first;
          selectedLocalImagePath.value = '';
          dobString.value = '';
          calculatedAge.value = 0;
          ageVerified.value = false;

          Get.snackbar('Age Verification Required', 'Please confirm your date of birth to continue.', snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.black);
          _showProfileSetupSheet();
          return;
        }

        final bool termsAccepted = data['termsAccepted'] == true;
        final String acceptedVersion = (data['policyVersion'] ?? '').toString();

        if (!termsAccepted || acceptedVersion != currentPolicyVersion) {
          await userRef.update({
            'termsAccepted': true,
            'communityAccepted': true,
            'policyVersion': currentPolicyVersion,
            'termsAcceptedAt': FieldValue.serverTimestamp(),
          });
        }

        await prefs.setBool('hasAccount', true);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', currentUid);
        await prefs.setString('userName', (data['name'] ?? 'Nova User').toString());
        await prefs.setBool('ugcAccepted', true);
        await prefs.setBool('ageVerified', true);
        await prefs.setString('policyVersion', currentPolicyVersion);

        isLoading.value = false;
        await _checkPermissionsAndNavigate();
      } else {
        isLoading.value = false;
        _resetForm();
        _showProfileSetupSheet();
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Login failed: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      debugPrint("One Tap Login Error: $e");
    }
  }

  void _showAgreementWarning() {
    Get.snackbar('Agreement Required', 'You must agree to the Terms, Privacy Policy, Community Guidelines, and Child Safety Standards to continue.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }

  void _resetForm() {
    nameController.clear();
    selectedGender.value = 'Male';
    dobString.value = '';
    calculatedAge.value = 0;
    ageVerified.value = false;
    selectedAvatar.value = defaultAvatars[0];
    selectedLocalImagePath.value = '';
  }

  Future<void> _pickDateOfBirth(BuildContext context) async {
    DateTime today = DateTime.now();
    DateTime initialDate = DateTime(today.year - 18, today.month, today.day);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.purpleAccent, onPrimary: Colors.white, surface: Color(0xFF1E1E1E), onSurface: Colors.white),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      dobString.value = formattedDate;
      int age = today.year - picked.year;
      if (today.month < picked.month || (today.month == picked.month && today.day < picked.day)) {
        age--;
      }
      calculatedAge.value = age;
      ageVerified.value = age >= 18;
    }
  }

  Future<void> pickCustomAvatar() async {
    bool userGaveConsent = await _showPhotoPermissionDisclosure();
    if (userGaveConsent) {
      try {
        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        if (pickedFile != null) {
          selectedLocalImagePath.value = pickedFile.path;
          selectedAvatar.value = '';
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to pick image: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }

  Future<bool> _showPhotoPermissionDisclosure() async {
    bool consent = false;
    await Get.defaultDialog(
      title: "Photo Access Required",
      titleStyle: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 18),
      backgroundColor: const Color(0xFF1E1E1E),
      radius: 15,
      content: const Column(
        children: [
          Icon(Icons.photo_library_rounded, size: 50, color: Colors.purpleAccent),
          SizedBox(height: 15),
          Text("Nova Live needs access to your photo library so you can choose a custom profile picture or live room logo.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
        ],
      ),
      barrierDismissible: false,
      cancel: TextButton(onPressed: () { consent = false; Get.back(); }, child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
        onPressed: () { consent = true; Get.back(); },
        child: const Text("Allow Access", style: TextStyle(color: Colors.white)),
      ),
    );
    return consent;
  }

  void _showProfileSetupSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text('Complete Profile', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            const Align(alignment: Alignment.centerLeft, child: Text('Choose Avatar', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            SizedBox(
              height: 75,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: pickCustomAvatar,
                    child: Obx(() {
                      bool hasLocalImage = selectedLocalImagePath.value.isNotEmpty;
                      return Container(
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: hasLocalImage ? Colors.purpleAccent : Colors.white24, width: hasLocalImage ? 3 : 1),
                          boxShadow: hasLocalImage ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10)] : [],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white10,
                          backgroundImage: hasLocalImage ? FileImage(File(selectedLocalImagePath.value)) : null,
                          child: hasLocalImage ? null : const Icon(Icons.add_a_photo, color: Colors.purpleAccent, size: 24),
                        ),
                      );
                    }),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: defaultAvatars.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            selectedAvatar.value = defaultAvatars[index];
                            selectedLocalImagePath.value = '';
                          },
                          child: Obx(() {
                            bool isSelected = selectedAvatar.value == defaultAvatars[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 15),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? Colors.purpleAccent : Colors.transparent, width: 3),
                                boxShadow: isSelected ? [BoxShadow(color: Colors.purpleAccent.withOpacity(0.5), blurRadius: 10)] : [],
                              ),
                              child: CircleAvatar(radius: 30, backgroundColor: Colors.white10, backgroundImage: NetworkImage(defaultAvatars[index])),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Your Nickname',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.person, color: Colors.purpleAccent),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            Obx(() => DropdownButtonFormField<String>(
              value: selectedGender.value,
              dropdownColor: const Color(0xFF2A2A2A),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.wc, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) selectedGender.value = newValue;
              },
            )),
            const SizedBox(height: 15),
            Obx(() => GestureDetector(
              onTap: () => _pickDateOfBirth(Get.context!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.orangeAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dobString.value.isEmpty ? 'Date of Birth (DD/MM/YYYY)' : dobString.value,
                        style: TextStyle(color: dobString.value.isEmpty ? Colors.grey : Colors.white, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.orangeAccent),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 35),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  shadowColor: Colors.purpleAccent.withOpacity(0.4),
                ),
                onPressed: isLoading.value ? null : _validateAndJoin,
                child: isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Join Now', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _validateAndJoin() async {
    String name = nameController.text.trim();
    if (name.isEmpty) { Get.snackbar('Error', 'Nickname cannot be empty.', backgroundColor: Colors.orangeAccent, colorText: Colors.black); return; }
    if (dobString.value.isEmpty) { Get.snackbar('Error', 'Please select your Date of Birth.', backgroundColor: Colors.orangeAccent, colorText: Colors.black); return; }
    if (calculatedAge.value < 18) { Get.snackbar('Access Denied 🛑', 'You must be at least 18 years old.', snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white); return; }

    isLoading.value = true;
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String uid;
      if (currentUser == null) {
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        uid = userCredential.user!.uid;
      } else {
        uid = currentUser.uid;
      }

      final String finalAvatarToSave = await _resolveAvatarUrl(uid);
      int dynamicWelcomeCoins = 0;
      try {
        DocumentSnapshot configDoc = await FirebaseFirestore.instance.collection('settings').doc('app_config').get();
        if (configDoc.exists && configDoc.data() != null) {
          final data = configDoc.data() as Map<String, dynamic>;
          dynamicWelcomeCoins = data['welcomeCoins'] ?? 0;
        }
      } catch (e) {}

      final DocumentReference<Map<String, dynamic>> userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> existingUser = await userRef.get();

      final Map<String, dynamic> userData = <String, dynamic>{
        'uid': uid,
        'name': name,
        'gender': selectedGender.value,
        'dob': dobString.value,
        'avatar': finalAvatarToSave,
        'ugcAcceptedAt': FieldValue.serverTimestamp(),
        'ageVerified': true,
        'ageVerifiedAt': FieldValue.serverTimestamp(),
        'policyVersion': currentPolicyVersion,
        'privacyAccepted': true,
        'termsAccepted': true,
        'communityAccepted': true,
        'childSafetyAccepted': true,
        'profileUpdatedAt': FieldValue.serverTimestamp(),
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      };

      if (!existingUser.exists) {
        userData.addAll(<String, dynamic>{
          'coins': dynamicWelcomeCoins,
          'totalEarnings': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await userRef.set(userData, SetOptions(merge: true));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasAccount', true);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', uid);
      await prefs.setString('device_linked_uid', uid);
      await prefs.setString('userName', name);
      await prefs.setBool('ugcAccepted', true);
      await prefs.setBool('ageVerified', true);
      await prefs.setString('policyVersion', currentPolicyVersion);

      isLoading.value = false;
      Get.back();
      _checkPermissionsAndNavigate();
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save data: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<String> _resolveAvatarUrl(String uid) async {
    final String remoteAvatar = selectedAvatar.value.trim();
    if (selectedLocalImagePath.value.isEmpty) {
      return remoteAvatar.isNotEmpty ? remoteAvatar : defaultAvatars.first;
    }
    try {
      final File imageFile = File(selectedLocalImagePath.value);
      if (!await imageFile.exists()) {
        return remoteAvatar.isNotEmpty ? remoteAvatar : defaultAvatars.first;
      }
      final Reference storageRef = _storage.ref().child('avatars/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final TaskSnapshot snapshot = await storageRef.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return remoteAvatar.isNotEmpty ? remoteAvatar : defaultAvatars.first;
    }
  }

  Future<void> _checkPermissionsAndNavigate() async {
    var cameraStatus = await Permission.camera.status;
    var micStatus = await Permission.microphone.status;
    if (cameraStatus.isGranted && micStatus.isGranted) {
      _goToHome();
    } else {
      _showProminentDisclosureDialog();
    }
  }

  void _showProminentDisclosureDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.security, color: Colors.purpleAccent),
            SizedBox(width: 10),
            Text('Permissions Required', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: const Text('To connect you with random matches via live video and audio calls, Nova Live requires access to your Camera and Microphone.\n\nWe strictly protect your privacy and do not record or store your personal calls on our servers.', style: TextStyle(color: Colors.white70, height: 1.5)),
        actions: [
          TextButton(onPressed: () { Get.back(); _goToHome(); }, child: const Text('Not Now', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async { Get.back(); _requestSystemPermissions(); },
            child: const Text('Allow Access', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _requestSystemPermissions() async {
    await [Permission.camera, Permission.microphone].request();
    _goToHome();
  }

  void _goToHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('userName') ?? 'User';
    Get.offAll(() => MainNavView(), transition: Transition.zoom);
    Get.snackbar('Welcome $name! 🚀', 'You are ready to match!', backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}