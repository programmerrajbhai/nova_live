import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../main_nav/view/main_nav_view.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();

  var isAgreed = false.obs;
  var isLoading = false.obs;

  var selectedGender = 'Male'.obs;
  var dobString = ''.obs;
  var calculatedAge = 0.obs;

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

  // ==========================================
  // ⚡ 1. One Tap Login (Anonymous)
  // ==========================================
  void onOneTapLoginClicked() async {
    if (!isAgreed.value) {
      _showAgreementWarning();
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAccount = prefs.getBool('hasAccount') ?? false;

    if (hasAccount) {
      isLoading.value = true;
      await prefs.setBool('isLoggedIn', true);
      isLoading.value = false;
      _checkPermissionsAndNavigate();
    } else {
      _resetForm();
      _showProfileSetupSheet();
    }
  }

  // ==========================================
  // 🌐 2. Sign In With Google (v7.2.0+ Latest API)
  // ==========================================
  Future<void> signInWithGoogle() async {
    if (!isAgreed.value) {
      _showAgreementWarning();
      return;
    }

    try {
      isLoading.value = true;

      // 🔥 ১. Google Sign-In এর নতুন 'instance' (v7.0+)
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // 🔥 ২. নতুন নিয়মে আগে 'initialize()' কল করতে হয়
      await googleSignIn.initialize();

      // 🔥 ৩. 'signIn()' এর বদলে এখন 'authenticate()' ব্যবহার করতে হয়
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        isLoading.value = false;
        return; // ইউজার পপআপ কেটে দিলে
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 🔥 ৪. ফায়ারবেসের জন্য এখন শুধু idToken লাগে, accessToken এর দরকার নেই
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = userCredential.user!.uid;

      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        // পুরানো ইউজার
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasAccount', true);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('uid', uid);
        await prefs.setString('userName', doc['name'] ?? 'User');
        await prefs.setBool('ugcAccepted', true);

        isLoading.value = false;
        _checkPermissionsAndNavigate();
      } else {
        // নতুন ইউজার
        _resetForm();
        nameController.text = userCredential.user!.displayName ?? '';
        selectedAvatar.value = userCredential.user!.photoURL ?? defaultAvatars[0];

        isLoading.value = false;
        _showProfileSetupSheet();
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Google Sign-In failed: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
      debugPrint("Google Auth Error: $e");
    }
  }

  void _showAgreementWarning() {
    Get.snackbar(
        'Agreement Required ⚠️',
        'You must agree to the UGC Policy, Terms, and Privacy Policy to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white
    );
  }

  void _resetForm() {
    nameController.clear();
    selectedGender.value = 'Male';
    dobString.value = '';
    calculatedAge.value = 0;
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
            colorScheme: const ColorScheme.dark(
              primary: Colors.purpleAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
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
          Text(
            "Nova Live needs access to your photo library so you can choose a custom profile picture or live room logo.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
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
    if (calculatedAge.value < 18) { Get.snackbar('Access Denied 🚫', 'You must be at least 18 years old.', snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white); return; }

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

      String finalAvatarToSave = selectedLocalImagePath.value.isNotEmpty ? selectedLocalImagePath.value : selectedAvatar.value;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'gender': selectedGender.value,
        'dob': dobString.value,
        'avatar': finalAvatarToSave,
        'coins': 500,
        'totalEarnings': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
        'ugcAcceptedAt': FieldValue.serverTimestamp(),
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasAccount', true);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uid', uid);
      await prefs.setString('userName', name);
      await prefs.setBool('ugcAccepted', true);

      isLoading.value = false;
      Get.back(); // Close Bottom Sheet

      _checkPermissionsAndNavigate();

    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save data: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        content: const Text(
          'To connect you with random matches via live video and audio calls, Nova Live requires access to your Camera and Microphone.\n\nWe strictly protect your privacy and do not record or store your personal calls on our servers.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
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
    Get.snackbar('Welcome $name! 🎉', 'You are ready to match!', backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}