import 'package:flutter/material.dart';

class StatsCards extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final stats;

  const StatsCards({
    Key? key,
    required this.isMobile,
    required this.isTablet,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate stats from arenas
    final moderationCount = stats['moderationCount'];

    int crossAxisCount = 4;
    if (isMobile) {
      crossAxisCount = 2;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.5 : 2.5,
      children: [
        _buildStatCard(
          'Новые на модерации',
          moderationCount.toString(),
          Colors.grey[700]!,
        ),
        _buildStatCard(
          'Средний рейтинг',
          '${stats['averageRating']} ⭐',
          const Color(0xFFFBBF24),
        ),
        _buildStatCard(
          'Кол-во бронирований (мес)',
          '${stats['totalBookings']}',
          Colors.grey[700]!,
        ),
        _buildStatCard(
          'Общий доход (мес)',
          '${stats['monthlyRevenue']} ₸',
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
