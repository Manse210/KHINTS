import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mock/mock_data.dart';
import '../models/document_model.dart';
import '../theme/app_colors.dart';
import '../widgets/badges.dart';
import 'document_detail_view.dart';

class SearchResultsView extends StatefulWidget {
  final String query;

  const SearchResultsView({super.key, required this.query});

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  String selectedFilter = 'Tous';
  final List<String> filters = ['Tous', 'DS', 'CC', 'Examen', 'Concours'];

  String _mapFilterToType(String filter) {
    switch (filter) {
      case 'Examen':
        return 'EX';
      case 'Concours':
        return 'CO';
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = MockData.documents.where((doc) {
      final q = widget.query.toLowerCase();
      final matchesQuery = doc.title.toLowerCase().contains(q) ||
          doc.department.toLowerCase().contains(q) ||
          doc.professorName.toLowerCase().contains(q) ||
          doc.departmentCode.toLowerCase().contains(q);
      final matchesType =
          selectedFilter == 'Tous' || doc.type == _mapFilterToType(selectedFilter);
      return matchesQuery && matchesType;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── DARK TOP BAR ───
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
                padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + Title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.white, size: 18),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Résultats — "${widget.query}"',
                            style: GoogleFonts.inter(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: filters.map((filter) {
                          final isSelected = selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedFilter = filter),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent
                                      : Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accent
                                        : Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: GoogleFonts.inter(
                                    color: AppColors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              '${results.length} documents trouvés',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // ─── RESULTS LIST ───
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun document trouvé.',
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return _buildResultCard(context, results[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Result card matching mockup: badge | title | chips row | downloads
  Widget _buildResultCard(BuildContext context, DocumentModel doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentDetailView(document: doc),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TypeBadge(type: doc.type, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Info chips row
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          InfoChip(label: doc.departmentCode),
                          InfoChip(label: doc.level, color: AppColors.success),
                          if (doc.year != null) InfoChip(label: doc.year!),
                          InfoChip(
                              label: doc.professorName,
                              color: AppColors.accent),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.download, size: 13, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            '${doc.downloads} téléchargements',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
