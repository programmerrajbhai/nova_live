import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../../legal/view/legal_views.dart';
import '../../../core/widgets/premium_background.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical -
                    56,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),

                    _buildLogo(),

                    const SizedBox(height: 24),

                    const Text(
                      'Nova Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      'Connect, stream and meet new people safely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),

                    const Spacer(),

                    _buildAgreementCard(),

                    const SizedBox(height: 20),

                    _buildLoginButton(),

                    const SizedBox(height: 15),

                    Text(
                      'A private device-linked Nova Live account may be '
                          'created when you continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 145,
      height: 145,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.03),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withValues(alpha: 0.34),
            blurRadius: 45,
            spreadRadius: 7,
          ),
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.20),
            blurRadius: 35,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.live_tv_rounded,
                color: Colors.purpleAccent,
                size: 75,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementCard() {
    return Obx(() {
      final agreed = controller.isAgreed.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
        decoration: BoxDecoration(
          color: agreed
              ? Colors.purpleAccent.withValues(alpha: 0.11)
              : const Color(0xFF151625).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: agreed
                ? Colors.purpleAccent.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: agreed
              ? [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.13),
              blurRadius: 20,
            ),
          ]
              : [],
        ),
        child: CheckboxListTile(
          value: agreed,
          onChanged: controller.toggleAgreement,
          activeColor: Colors.purpleAccent,
          checkColor: Colors.white,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                fontSize: 12,
                height: 1.6,
              ),
              children: [
                const TextSpan(
                  text:
                  'I confirm that I am at least 18 years old and agree to the ',
                ),

                _policyLink(
                  'Terms of Service',
                      () => Get.to(() => const TermsConditionsView()),
                ),

                const TextSpan(text: ', '),

                _policyLink(
                  'Community Guidelines',
                      () => Get.to(() => const PlayPolicyView()),
                ),

                const TextSpan(text: ', '),

                _policyLink(
                  'Privacy Policy',
                      () => Get.to(() => const PrivacyPolicyView()),
                ),

                const TextSpan(text: ' and '),

                _policyLink(
                  'Child Safety Standards',
                      () => Get.to(() => const ChildSafetyView()),
                  color: const Color(0xFFFF6B6B),
                ),

                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      );
    });
  }

  TextSpan _policyLink(
      String text,
      VoidCallback onTap, {
        Color color = Colors.purpleAccent,
      }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        decoration: TextDecoration.underline,
        decorationColor: color,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  Widget _buildLoginButton() {
    return Obx(() {
      final loading = controller.isLoading.value;

      return GestureDetector(
        onTap: loading ? null : controller.onOneTapLoginClicked,
        child: AnimatedOpacity(
          opacity: loading ? 0.75 : 1,
          duration: const Duration(milliseconds: 180),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF2BA6),
                  Color(0xFF9C27FF),
                  Color(0xFF315BFF),
                ],
              ),
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: Colors.purpleAccent.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: Colors.yellowAccent,
                    size: 27,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Continue to Nova Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}