import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../mock/mock_data.dart';
import 'search_results_view.dart';

class BrowseView extends StatelessWidget {
  const BrowseView({super.key});

  @override
  Widget build(BuildContext context) {
    final deptColors = [AppColors.deptGI, AppColors.deptBio, AppColors.deptMeca, AppColors.deptGestion];
    final deptIcons = [Icons.computer, Icons.biotech, Icons.precision_manufacturing, Icons.bar_chart];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.navyDark, AppColors.navy]),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Text('Parcourir', style: GoogleFonts.inter(color: AppColors.white, fontWeight: FontWeight.w800, fontSize: 22)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: MockData.departments.length,
              itemBuilder: (context, index) {
                final dept = MockData.departments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Material(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultsView(query: dept['code'] as String)));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBlue),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: deptColors[index].withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                              child: Icon(deptIcons[index], color: deptColors[index], size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dept['name'] as String, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text('${dept['count']} documents', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
