import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'login_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navyDark, AppColors.navy],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.accent, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text('Étudiant ESP', style: GoogleFonts.inter(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('Non connecté', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _menuItem(Icons.login, 'Se connecter', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                  }),
                  _menuItem(Icons.info_outline, 'À propos de KHINTS+', () {}),
                  _menuItem(Icons.dark_mode, 'Mode sombre', () {}),
                  _menuItem(Icons.help_outline, 'Aide', () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 22),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14))),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
