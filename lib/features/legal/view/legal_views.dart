import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String novaSupportEmail = 'REPLACE_WITH_REAL_SUPPORT_EMAIL';
const String policyLastUpdated = 'August 4, 2026';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_rounded,
      subtitle: 'How Nova Live handles and protects your information.',
      sections: [
        LegalSection(
          icon: Icons.person_outline_rounded,
          title: 'Information We Collect',
          content:
          'Nova Live may collect your nickname, date of birth, gender, '
              'profile image, account identifier, profile information, chat '
              'messages, reports, block records, room activity and other '
              'information you choose to provide.',
        ),
        LegalSection(
          icon: Icons.calendar_month_rounded,
          title: 'Age Information',
          content:
          'Nova Live is intended only for users who are at least 18 years '
              'old. Date-of-birth information is used to determine eligibility '
              'and support platform safety.',
        ),
        LegalSection(
          icon: Icons.mic_rounded,
          title: 'Microphone',
          content:
          'Microphone access is used when you join live audio rooms or '
              'voice communication features. Permission should only be '
              'requested when the feature needs it.',
        ),
        LegalSection(
          icon: Icons.camera_alt_rounded,
          title: 'Camera and Photos',
          content:
          'Camera or photo access may be used for profile images, room '
              'images and supported video features. Nova Live does not access '
              'your media without an action initiated by you.',
        ),
        LegalSection(
          icon: Icons.cloud_outlined,
          title: 'Firebase Services',
          content:
          'Nova Live uses Firebase services for authentication, database '
              'storage, media storage and related app functionality. Data may '
              'be processed by these service providers to operate the app.',
        ),
        LegalSection(
          icon: Icons.live_tv_rounded,
          title: 'Live Communication Services',
          content:
          'Nova Live uses third-party real-time communication technology, '
              'including ZEGOCLOUD, to provide audio rooms and communication '
              'features. Media and technical data may be processed as required '
              'to deliver those services.',
        ),
        LegalSection(
          icon: Icons.ads_click_rounded,
          title: 'Advertising',
          content:
          'Nova Live may use Google Mobile Ads. Advertising providers may '
              'process advertising identifiers, device information, ad '
              'interactions and diagnostic information according to their '
              'own policies and your available consent choices.',
        ),
        LegalSection(
          icon: Icons.gavel_rounded,
          title: 'Moderation and Safety',
          content:
          'Messages, profiles, rooms and reports may be processed to '
              'detect abuse, enforce Community Guidelines, investigate '
              'complaints and protect users.',
        ),
        LegalSection(
          icon: Icons.delete_forever_rounded,
          title: 'Account Deletion',
          content:
          'You can request permanent account deletion from the app. Nova '
              'Live will delete or anonymize associated data unless retention '
              'is required for security, fraud prevention, legal compliance '
              'or resolving active reports.',
        ),
        LegalSection(
          icon: Icons.security_rounded,
          title: 'Security',
          content:
          'We use reasonable technical and organizational safeguards. '
              'However, no internet service can guarantee absolute security.',
        ),
        LegalSection(
          icon: Icons.mail_outline_rounded,
          title: 'Privacy Contact',
          content:
          'Questions or requests concerning privacy can be sent to:\n'
              '$novaSupportEmail',
        ),
      ],
    );
  }
}

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: 'Terms of Service',
      icon: Icons.description_rounded,
      subtitle: 'Rules governing access to and use of Nova Live.',
      sections: [
        LegalSection(
          icon: Icons.verified_user_rounded,
          title: 'Eligibility',
          content:
          'You must be at least 18 years old to create or use a Nova Live '
              'account. By continuing, you confirm that the information you '
              'provide is truthful and accurate.',
        ),
        LegalSection(
          icon: Icons.account_circle_rounded,
          title: 'Your Account',
          content:
          'You are responsible for activity performed through your '
              'account or device-linked session. You must not impersonate '
              'another person, evade enforcement or create accounts for abuse.',
        ),
        LegalSection(
          icon: Icons.groups_rounded,
          title: 'User-Generated Content',
          content:
          'You are responsible for content and behavior you contribute. '
              'Content must comply with these Terms, Community Guidelines, '
              'Child Safety Standards and applicable laws.',
        ),
        LegalSection(
          icon: Icons.block_rounded,
          title: 'Prohibited Conduct',
          content:
          'Harassment, hate speech, sexual exploitation, child '
              'endangerment, threats, scams, spam, impersonation, illegal '
              'activity, privacy violations and attempts to bypass safety '
              'controls are prohibited.',
        ),
        LegalSection(
          icon: Icons.report_rounded,
          title: 'Reports and Enforcement',
          content:
          'Nova Live may review reports, restrict features, remove '
              'content, terminate rooms, suspend accounts or permanently ban '
              'users when violations are detected.',
        ),
        LegalSection(
          icon: Icons.diamond_outlined,
          title: 'Virtual Items',
          content:
          'Virtual coins, diamonds, gifts or rewards have no cash value '
              'unless Nova Live explicitly states otherwise. They may not be '
              'sold, transferred or exchanged outside approved app features.',
        ),
        LegalSection(
          icon: Icons.warning_amber_rounded,
          title: 'Service Availability',
          content:
          'Nova Live may modify, suspend or discontinue features for '
              'maintenance, security, legal or operational reasons.',
        ),
        LegalSection(
          icon: Icons.logout_rounded,
          title: 'Termination',
          content:
          'You may stop using Nova Live or delete your account. Nova Live '
              'may restrict or terminate accounts that violate these Terms or '
              'create safety, legal or security risks.',
        ),
        LegalSection(
          icon: Icons.mail_outline_rounded,
          title: 'Contact',
          content: 'For support, contact:\n$novaSupportEmail',
        ),
      ],
    );
  }
}

class PlayPolicyView extends StatelessWidget {
  const PlayPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: 'Community Guidelines',
      icon: Icons.groups_2_rounded,
      subtitle: 'Help keep Nova Live respectful, safe and welcoming.',
      sections: [
        LegalSection(
          icon: Icons.favorite_rounded,
          title: 'Respect Other Users',
          content:
          'Treat users respectfully. Bullying, repeated unwanted contact, '
              'humiliation, intimidation and targeted harassment are not allowed.',
        ),
        LegalSection(
          icon: Icons.record_voice_over_rounded,
          title: 'No Hate or Threats',
          content:
          'Do not promote hatred, violence or discrimination against '
              'individuals or protected groups. Credible threats are prohibited.',
        ),
        LegalSection(
          icon: Icons.no_adult_content_rounded,
          title: 'No Sexual Exploitation',
          content:
          'Sexual exploitation, non-consensual intimate content, sexual '
              'coercion, solicitation and sexually abusive behavior are prohibited.',
        ),
        LegalSection(
          icon: Icons.child_care_rounded,
          title: 'Protect Children',
          content:
          'Content or behavior involving child sexual abuse, exploitation, '
              'grooming, sextortion, trafficking or sexualization of minors is '
              'strictly prohibited and may be reported to relevant authorities.',
          isCritical: true,
        ),
        LegalSection(
          icon: Icons.person_off_rounded,
          title: 'No Impersonation',
          content:
          'Do not pretend to be another person, public figure, company, '
              'moderator or Nova Live representative.',
        ),
        LegalSection(
          icon: Icons.mark_email_unread_rounded,
          title: 'No Spam or Scams',
          content:
          'Do not send repetitive promotions, fraudulent offers, phishing '
              'links, payment scams, deceptive investment offers or malware.',
        ),
        LegalSection(
          icon: Icons.lock_person_rounded,
          title: 'Respect Privacy',
          content:
          'Do not expose private information, record private conversations '
              'without permission or share another person’s personal content.',
        ),
        LegalSection(
          icon: Icons.report_problem_rounded,
          title: 'Report and Block',
          content:
          'Use in-app reporting and blocking tools when you encounter '
              'abusive users, messages, profiles or live rooms. False or '
              'malicious reports may also result in action.',
        ),
        LegalSection(
          icon: Icons.admin_panel_settings_rounded,
          title: 'Enforcement',
          content:
          'Violations may result in warnings, content removal, room '
              'termination, temporary restrictions, suspension or permanent bans.',
        ),
      ],
    );
  }
}

class UserAgreementView extends StatelessWidget {
  const UserAgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: 'UGC Policy',
      icon: Icons.forum_rounded,
      subtitle: 'Rules for profiles, messages, rooms and user-created content.',
      sections: [
        LegalSection(
          icon: Icons.edit_note_rounded,
          title: 'Your Responsibility',
          content:
          'You are responsible for all content, profile information, '
              'messages, audio and room activity submitted through your account.',
        ),
        LegalSection(
          icon: Icons.rule_rounded,
          title: 'Allowed Content',
          content:
          'Content must be lawful, consensual, authentic and appropriate '
              'for an adult social and live communication platform.',
        ),
        LegalSection(
          icon: Icons.dangerous_rounded,
          title: 'Prohibited Content',
          content:
          'Abusive, exploitative, hateful, threatening, fraudulent, '
              'privacy-invasive, illegal or child-endangering content is prohibited.',
        ),
        LegalSection(
          icon: Icons.manage_search_rounded,
          title: 'Content Review',
          content:
          'Nova Live may use automated filters and human review to process '
              'reported content and enforce platform rules.',
        ),
        LegalSection(
          icon: Icons.flag_rounded,
          title: 'Reporting',
          content:
          'Users must be able to report inappropriate profiles, messages, '
              'users and live rooms through available in-app controls.',
        ),
        LegalSection(
          icon: Icons.block_flipped,
          title: 'Blocking',
          content:
          'Users may block other users to stop or limit unwanted direct '
              'interaction according to the features available in the app.',
        ),
        LegalSection(
          icon: Icons.delete_sweep_rounded,
          title: 'Removal',
          content:
          'Nova Live may remove content or restrict accounts when content '
              'violates policy, creates risk or is required by law.',
        ),
      ],
    );
  }
}

class ChildSafetyView extends StatelessWidget {
  const ChildSafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentView(
      title: 'Child Safety Standards',
      icon: Icons.health_and_safety_rounded,
      subtitle:
      'Nova Live has zero tolerance for child sexual abuse and exploitation.',
      accentColor: Color(0xFFFF5252),
      sections: [
        LegalSection(
          icon: Icons.no_accounts_rounded,
          title: 'Adults Only',
          content:
          'Nova Live is intended only for people aged 18 or older. Users '
              'who are identified as underage may be restricted or removed.',
          isCritical: true,
        ),
        LegalSection(
          icon: Icons.child_care_rounded,
          title: 'Zero Tolerance for CSAE',
          content:
          'Child sexual abuse and exploitation, sexualization of minors, '
              'grooming, sextortion, trafficking and requests for sexual '
              'content involving minors are strictly prohibited.',
          isCritical: true,
        ),
        LegalSection(
          icon: Icons.image_not_supported_rounded,
          title: 'CSAM Prohibited',
          content:
          'Users must never create, request, possess, upload, transmit or '
              'distribute child sexual abuse material through Nova Live.',
          isCritical: true,
        ),
        LegalSection(
          icon: Icons.report_rounded,
          title: 'Report Immediately',
          content:
          'Users should immediately report suspected child exploitation '
              'through in-app reporting tools. Select the Child Safety reason '
              'and provide accurate information.',
        ),
        LegalSection(
          icon: Icons.policy_rounded,
          title: 'Our Response',
          content:
          'Nova Live may preserve relevant evidence, remove content, '
              'terminate rooms, suspend accounts and report confirmed illegal '
              'activity to appropriate authorities as required by law.',
        ),
        LegalSection(
          icon: Icons.support_agent_rounded,
          title: 'Child Safety Contact',
          content:
          'Child-safety concerns and official notices can be sent to:\n'
              '$novaSupportEmail',
        ),
      ],
    );
  }
}

class LegalDocumentView extends StatelessWidget {
  final String title;
  final IconData icon;
  final String subtitle;
  final List<LegalSection> sections;
  final Color accentColor;

  const LegalDocumentView({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.sections,
    this.accentColor = const Color(0xFFE040FB),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090A14),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
              Color(0xFF271044),
              Color(0xFF101225),
              Color(0xFF090A14),
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              ...sections.map(
                    (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LegalSectionCard(
                    section: section,
                    accentColor: accentColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.25),
            const Color(0xFF16172A),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.14),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(icon, color: accentColor, size: 38),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              height: 1.5,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Last updated: $policyLastUpdated',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Image.asset(
          'assets/images/app_icon.png',
          width: 56,
          height: 56,
          errorBuilder: (_, __, ___) => Icon(
            Icons.live_tv_rounded,
            color: accentColor,
            size: 45,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Nova Live',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Safety • Privacy • Respect',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class LegalSection {
  final IconData icon;
  final String title;
  final String content;
  final bool isCritical;

  const LegalSection({
    required this.icon,
    required this.title,
    required this.content,
    this.isCritical = false,
  });
}

class _LegalSectionCard extends StatelessWidget {
  final LegalSection section;
  final Color accentColor;

  const _LegalSectionCard({
    required this.section,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = section.isCritical
        ? const Color(0xFFFF5252)
        : accentColor;

    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161725).withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: effectiveColor.withValues(alpha: 0.22),
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 5,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: effectiveColor,
          collapsedIconColor: Colors.white38,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              section.icon,
              color: effectiveColor,
              size: 23,
            ),
          ),
          title: Text(
            section.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                section.content,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  height: 1.65,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}