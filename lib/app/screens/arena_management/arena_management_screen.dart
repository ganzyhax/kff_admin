import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/bloc/arena_management_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_header.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_stats_card.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_table_card.dart';

class ArenaManagementScreen extends StatelessWidget {
  const ArenaManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: BlocProvider(
        create: (context) => ArenaManagementBloc()..add(ArenaManagementLoad()),
        child: BlocBuilder<ArenaManagementBloc, ArenaManagementState>(
          builder: (context, state) {
            if (state is ArenaManagementLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade600,
                  ),
                ),
              );
            }

            if (state is ArenaManagementLoaded) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Commission & Cashback
                      ArenaHeader(
                        isMobile: isMobile,
                        commission: state.commission ?? 12,
                        cashback: state.cashback ?? 5,
                      ),
                      const SizedBox(height: 32),

                      // Stats Cards
                      StatsCards(
                        isMobile: isMobile,
                        isTablet: isTablet,
                        stats: state.stats,
                      ),
                      const SizedBox(height: 32),

                      // Arenas Table
                      ArenasTable(
                        isMobile: isMobile,
                        isTablet: isTablet,
                        arenas: state.arenas,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ArenaManagementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
