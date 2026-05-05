import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class UploadView extends StatefulWidget {
  const UploadView({super.key});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  String? selectedDepartment;
  String? selectedLevel;
  String? selectedType;

  final titleController = TextEditingController();
  final professorController = TextEditingController();
  final yearController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── DARK HEADER ───
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Déposer un khint',
                      style: GoogleFonts.inter(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Contribuez à aider vos camarades en partageant une ancienne épreuve.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── FORM BODY ───
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // File upload area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.accent.withOpacity(0.3),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.description_outlined,
                            size: 40,
                            color: AppColors.accent.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Importer un PDF',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Glisser ou sélectionner un fichier',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Choisir un fichier',
                            style: GoogleFonts.inter(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form fields
                  _buildLabel('Titre du document'),
                  _buildTextField(titleController, 'Algo DS 2024', suffix: 'Semestre 2'),
                  const SizedBox(height: 18),

                  _buildLabel('Département'),
                  _buildDropdown(
                    value: selectedDepartment,
                    hint: 'Génie Informatique (DGI)',
                    items: ['Génie Informatique (DGI)', 'Biologie (DBio)', 'Génie Mécanique (DGM)', 'Gestion (DGes)'],
                    onChanged: (v) => setState(() => selectedDepartment = v),
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Niveau'),
                  _buildDropdown(
                    value: selectedLevel,
                    hint: 'Sélectionner (L1, L2, L3, M1...)',
                    items: ['L1', 'L2', 'L3', 'M1', 'M2', 'DIC1', 'DIC2', 'DIC3'],
                    onChanged: (v) => setState(() => selectedLevel = v),
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Professeur'),
                  _buildTextField(professorController, 'Nom du professeur'),
                  const SizedBox(height: 18),

                  _buildLabel('Type'),
                  _buildDropdown(
                    value: selectedType,
                    hint: 'DS / CC / Examen / Concours',
                    items: ['DS', 'CC', 'Examen', 'Concours'],
                    onChanged: (v) => setState(() => selectedType = v),
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Année académique'),
                  _buildTextField(yearController, 'Ex: 2023-2024'),
                  const SizedBox(height: 24),

                  // Warning notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock, size: 18, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                    text: 'Connexion requise. ',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                const TextSpan(
                                    text: 'Pour contribuer, vous devez être connecté avec votre adresse institutionnelle '),
                                TextSpan(
                                    text: '@esp.sn',
                                    style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600)),
                                const TextSpan(text: ' ou '),
                                TextSpan(
                                    text: '@ucad.edu.sn',
                                    style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600)),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document soumis pour modération ! (Simulation)'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Soumettre le document',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Le document sera examiné par un administrateur avant publication.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {String? suffix}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixText: suffix,
          suffixStyle:
              GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBlue),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style:
                  GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.inter(fontSize: 14))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
