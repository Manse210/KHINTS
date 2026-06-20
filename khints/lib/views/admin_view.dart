import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : AppColors.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('documents').snapshots(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data?.docs ?? [];
          final pending = allDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['isValidated'] == false;
          }).toList();
          final validated = allDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return data['isValidated'] == true;
          }).toList();

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Container(
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
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.admin_panel_settings,
                                  color: AppColors.accent, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('Admin KHINTS+',
                                    style: GoogleFonts.inter(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout,
                                    color: AppColors.textSecondary),
                                onPressed: () =>
                                    FirebaseAuth.instance.signOut(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _statCard('${allDocs.length}', 'Total docs',
                                  AppColors.accent),
                              const SizedBox(width: 10),
                              _statCard('${validated.length}', 'Validés',
                                  AppColors.success),
                              const SizedBox(width: 10),
                              _statCard('${pending.length}', 'En attente',
                                  AppColors.warning),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSeeding ? null : _seedTestData,
                              icon: _isSeeding
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white))
                                  : const Icon(Icons.storage, size: 18),
                              label: Text(
                                  _isSeeding
                                      ? 'Suppression...'
                                      : 'Supprimer tout & recréer les données test',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: BorderSide(
                                    color: Colors.white.withValues(
                                        alpha: 0.3)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _showSendNotificationDialog,
                              icon: const Icon(Icons.notifications, size: 18),
                              label: Text('Tester notification push',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.white,
                                side: BorderSide(
                                    color: Colors.white.withValues(
                                        alpha: 0.3)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: isDark ? DarkColors.background : AppColors.background,
                  child: TabBar(
                    controller: _tabController,
                    labelStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
                    labelColor: AppColors.accent,
                    unselectedLabelColor: isDark ? DarkColors.textSecondary : AppColors.textSecondary,
                    indicatorColor: AppColors.accent,
                    tabs: [
                      Tab(text: 'En attente (${pending.length})'),
                      Tab(text: 'Validés (${validated.length})'),
                      const Tab(text: 'Utilisateurs'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildDocList(pending, showValidate: true),
                _buildDocList(validated, showValidate: false),
                _buildUserList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocList(List<QueryDocumentSnapshot> docs,
      {required bool showValidate}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64,
                color: AppColors.success.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Aucun document',
                style: GoogleFonts.inter(
                    color: isDark ? DarkColors.textSecondary : AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final docId = docs[index].id;
        return _buildDocCard(data, docId, showValidate: showValidate);
      },
    );
  }

  Widget _buildDocCard(Map<String, dynamic> data, String docId,
      {required bool showValidate}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.card : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? DarkColors.border : AppColors.lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: showValidate
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    showValidate ? 'En attente' : 'Validé',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            showValidate ? AppColors.warning : AppColors.success)),
              ),
              const Spacer(),
              Text(data['type'] ?? '',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(data['title'] ?? '',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? DarkColors.textPrimary : AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(
              '${data['professorName'] ?? ''} · ${data['departmentCode'] ?? ''} · ${data['level'] ?? ''}',
              style: GoogleFonts.inter(
                  fontSize: 11, color: isDark ? DarkColors.textSecondary : AppColors.textSecondary)),
          if (data['uploadDate'] != null)
            Text(
                'Uploadé le ${_formatDate(data['uploadDate'])}',
                style: GoogleFonts.inter(
                    fontSize: 10, color: isDark ? DarkColors.textSecondary : AppColors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            children: [
              if (showValidate)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _validateDoc(docId, data['title'] ?? '', data['departmentCode'] ?? ''),
                    icon: const Icon(Icons.check, size: 16),
                    label: Text('Valider',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              if (showValidate) const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deleteDoc(docId),
                  icon: const Icon(Icons.delete, size: 16),
                  label: Text('Supprimer',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        final users = snapshot.data?.docs ?? [];
        if (users.isEmpty) {
          return Center(
            child: Text('Aucun utilisateur',
                style: GoogleFonts.inter(color: isDark ? DarkColors.textSecondary : AppColors.textSecondary)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final data = users[index].data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? DarkColors.card : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? DarkColors.border : AppColors.lightBlue),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppColors.accent.withValues(alpha: 0.15),
                    child: Text(
                        (data['fullName'] ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.inter(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['fullName'] ?? 'Sans nom',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 13, color: isDark ? DarkColors.textPrimary : AppColors.textPrimary)),
                        Text(data['email'] ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? DarkColors.textSecondary : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(data['role'] ?? 'etudiant',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? DarkColors.textSecondary : AppColors.textSecondary)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return date?.toString() ?? '';
    }
  }

  Future<void> _validateDoc(String docId, String title, String departmentCode) async {
    await FirebaseFirestore.instance.collection('documents').doc(docId).update({
      'isValidated': true,
    });
    final service = NotificationService();
    await service.sendToAll('Nouveau document validé 📄', '"$title" est maintenant disponible en $departmentCode');
  }

  Future<void> _deleteDoc(String docId) async {
    await FirebaseFirestore.instance.collection('documents').doc(docId).delete();
  }

  Future<void> _seedTestData() async {
    setState(() => _isSeeding = true);
    try {
      final docs = await FirebaseFirestore.instance.collection('documents').get();
      for (final doc in docs.docs) {
        await doc.reference.delete();
      }

      const fileUrl =
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

      final testDocs = [
        {
          'title': 'DS Architecture des Ordinateurs',
          'department': 'Génie Informatique',
          'departmentCode': 'DGI',
          'level': 'L2',
          'type': 'DS',
          'professorName': 'Dr. Fatou Diop',
          'professorInitials': 'FD',
          'uploadDate': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 45,
          'google_drive_file_id': fileUrl,
          'fileSize': '2.4 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'CC Programmation Java Avancée',
          'department': 'Génie Informatique',
          'departmentCode': 'DGI',
          'level': 'L3',
          'type': 'CC',
          'professorName': 'Dr. Oumar Ndiaye',
          'professorInitials': 'ON',
          'uploadDate': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 32,
          'google_drive_file_id': fileUrl,
          'fileSize': '1.8 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'Examen Réseaux Télécoms',
          'department': 'Génie Informatique',
          'departmentCode': 'DGI',
          'level': 'L3',
          'type': 'Examen',
          'professorName': 'Dr. Abdoulaye Fall',
          'professorInitials': 'AF',
          'uploadDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 78,
          'google_drive_file_id': fileUrl,
          'fileSize': '3.1 MB',
          'year': '2023-2024',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'TD Analyse Numérique',
          'department': 'Génie Informatique',
          'departmentCode': 'DGI',
          'level': 'L3',
          'type': 'TD',
          'professorName': 'Dr. Fatou Diop',
          'professorInitials': 'FD',
          'uploadDate': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 15,
          'google_drive_file_id': fileUrl,
          'fileSize': '1.2 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'DS Thermodynamique',
          'department': 'Génie Mécanique',
          'departmentCode': 'DGM',
          'level': 'L2',
          'type': 'DS',
          'professorName': 'Dr. Moussa Sow',
          'professorInitials': 'MS',
          'uploadDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 22,
          'google_drive_file_id': fileUrl,
          'fileSize': '2.0 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'Examen Biochimie Structurale',
          'department': 'Biologie',
          'departmentCode': 'DBio',
          'level': 'L2',
          'type': 'Examen',
          'professorName': 'Dr. Aïssatou Kane',
          'professorInitials': 'AK',
          'uploadDate': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 55,
          'google_drive_file_id': fileUrl,
          'fileSize': '2.7 MB',
          'year': '2023-2024',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'CC Comptabilité Analytique',
          'department': 'Gestion',
          'departmentCode': 'DGes',
          'level': 'L3',
          'type': 'CC',
          'professorName': 'Dr. Marième Diallo',
          'professorInitials': 'MD',
          'uploadDate': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 38,
          'google_drive_file_id': fileUrl,
          'fileSize': '1.5 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
        {
          'title': 'DS Mécanique des Fluides',
          'department': 'Génie Mécanique',
          'departmentCode': 'DGM',
          'level': 'L3',
          'type': 'DS',
          'professorName': 'Dr. Ibrahima Ba',
          'professorInitials': 'IB',
          'uploadDate': DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
          'downloads': 29,
          'google_drive_file_id': fileUrl,
          'fileSize': '2.2 MB',
          'year': '2024-2025',
          'isValidated': false,
          '_notified': false,
        },
      ];

      for (final doc in testDocs) {
        await FirebaseFirestore.instance.collection('documents').add(doc);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('8 documents de test créés avec fichier !'),
            backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  void _showSendNotificationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Envoyer une notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Colle le token d\'accès FCM généré par Gemini CLI'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Access token...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sendTestNotification(controller.text);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotification(String accessToken) async {
    if (accessToken.isEmpty) return;
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('notificationsEnabled', isEqualTo: true)
          .get();
      final tokens = <String>[];
      for (final user in users.docs) {
        final t = user.data()['fcmToken'] as String?;
        if (t != null && t.isNotEmpty) tokens.add(t);
      }
      if (tokens.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun utilisateur avec notifications activées'), backgroundColor: AppColors.warning),
        );
        return;
      }

      final httpClient = http.Client();
      try {
        for (final token in tokens) {
          await httpClient.post(
            Uri.parse('https://fcm.googleapis.com/v1/projects/khint-1fb73/messages:send'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'message': {
                'token': token,
                'notification': {'title': 'KHINTS+', 'body': 'Test notification depuis l\'admin'},
              },
            }),
          );
        }
      } finally {
        httpClient.close();
      }

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification envoyée à ${tokens.length} appareil(s)'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.danger),
      );
    }
  }
}
