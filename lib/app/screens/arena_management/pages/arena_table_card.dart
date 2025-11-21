import 'package:flutter/material.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_desktop_table.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_mobile_list.dart';

class ArenasTable extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final List<dynamic> arenas;

  const ArenasTable({
    Key? key,
    required this.isMobile,
    required this.isTablet,
    required this.arenas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Список всех арен',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),

          // Table
          if (isMobile)
            MobileArenaList(arenas: arenas)
          else
            DesktopArenaTable(arenas: arenas, isTablet: isTablet),
        ],
      ),
    );
  }
}
