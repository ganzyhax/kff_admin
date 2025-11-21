// lib/screens/admin/admin_dashboard_page.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kff_super_admin/app/api/api.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _error;

  // Overview Stats
  Map<String, dynamic>? _overviewStats;

  // Top Arenas
  List<Map<String, dynamic>> _topArenas = [];
  Map<String, dynamic>? _topArenasSummary;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.wait([_fetchOverviewStats(), _fetchTopArenas()]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchOverviewStats() async {
    try {
      final response = await ApiClient.get('api/dashboard/admin/overview');

      if (response['success'] == true) {
        setState(() {
          _overviewStats = response['data']['data'];
          log(_overviewStats.toString());
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load overview stats');
      }
    } catch (e) {
      throw Exception('Error loading overview: $e');
    }
  }

  Future<void> _fetchTopArenas() async {
    try {
      final response = await ApiClient.get(
        'api/dashboard/admin/top-arenas?limit=10',
      );

      if (response['success']) {
        final data =
            response['data'] ?? response; // ← На случай двойной вложенности
        log(response.toString() + 'toparenastoparenastoparenas');

        setState(() {
          _topArenasSummary = data['summary'];
          _topArenas = List<Map<String, dynamic>>.from(
            (data['arenas'] as List).map(
              (arena) => {
                'id': arena['id'],
                'name': arena['name'],
                'address': arena['address'],
                'ownerName': arena['owner']['name'],
                'ownerEmail': arena['owner']['email'],
                'ownerPhone': arena['owner']['phone'],
                'bookings': arena['stats']['bookingsCount'],
                'completedBookings': arena['stats']['completedBookings'],
                'hours': arena['stats']['totalHours'],
                'revenue': arena['stats']['grossRevenue'], // ✅ ИСПРАВЛЕНО!
                'commission':
                    arena['stats']['platformCommission'], // ✅ ИСПРАВЛЕНО!
                'netRevenue': arena['stats']['netRevenue'], // ✅ ДОБАВЛЕНО!
                'rating': arena['stats']['rating'],
                'ratedCount': arena['stats']['ratedBookingsCount'],
                'prepaidAmount': arena['prepaidAmount'],
                'pendingPayment': arena['pendingPayment'],
              },
            ),
          );
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load top arenas');
      }
    } catch (e) {
      throw Exception('Error loading top arenas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _buildErrorWidget()
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 768;

                  return RefreshIndicator(
                    onRefresh: _loadDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(isMobile),
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildStatCards(isMobile),
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildTopArenasSection(isMobile),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки данных',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Неизвестная ошибка',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboardData,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    final period = _overviewStats?['period'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Обзор Системы',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Админ-Панель',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (period != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      period['month'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCards(bool isMobile) {
    if (_overviewStats == null) return const SizedBox.shrink();

    final arenas = _overviewStats!['arenas'];
    final users = _overviewStats!['users'];
    final finance = _overviewStats!['finance'];
    final bookings = _overviewStats!['bookings'];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (isMobile) {
          crossAxisCount = 1;
          childAspectRatio = 3.5;
        } else if (constraints.maxWidth < 1024) {
          crossAxisCount = 2;
          childAspectRatio = 2.5;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 1.8;
        }
        log(finance.toString() + 'a,a,a,a,,a,');
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              icon: Icons.sports_soccer,
              iconColor: Colors.blue.shade600,
              iconBgColor: Colors.blue.shade50,
              label: 'Всего Арен',
              value: arenas['total'].toString(),
              subtitle: 'Активных: ${arenas['active']}',
              valueColor: Colors.blue.shade800,
            ),
            _buildStatCard(
              icon: Icons.people_alt,
              iconColor: Colors.orange.shade700,
              iconBgColor: Colors.orange.shade50,
              label: 'Всего пользователей',
              value: _formatNumber(users['players']),
              subtitle: 'Игроки',
              valueColor: Colors.orange.shade800,
            ),

            _buildStatCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: Colors.green.shade700,
              iconBgColor: Colors.green.shade50,
              label: 'Доход владельцев',
              value: _formatCurrency(finance['platformCommission']),
              subtitle: 'С учётом комиссии',
              valueColor: Colors.green.shade800,
            ),
            _buildStatCard(
              icon: Icons.receipt_long,
              iconColor: Colors.purple.shade600,
              iconBgColor: Colors.purple.shade50,
              label: 'Комиссия (Месяц)',
              value: _formatCurrency(
                finance['platformCommission'],
              ), // ✅ ИСПРАВЛЕНО!
              subtitle: '${finance['commissionPercentage']}% от доходов',
              valueColor: Colors.purple.shade600,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
    String? subtitle,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopArenasSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Самые Активные Арены (Месяц)',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Арены с наибольшим количеством бронирований и сгенерированной комиссией',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Summary cards
          if (_topArenasSummary != null) ...[
            SizedBox(height: isMobile ? 16 : 20),
            _buildSummaryCards(isMobile),
          ],

          SizedBox(height: isMobile ? 16 : 24),

          if (_topArenas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Нет данных',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (isMobile)
            _buildMobileArenaList()
          else
            _buildDesktopArenaTable(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isMobile) {
    final summary = _topArenasSummary!;
    log(summary.toString() + 'summarysummarysummary');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isMobile
          ? Column(
              children: [
                _buildSummaryItem(
                  'Всего Бронирований',
                  summary['totalBookings'].toString(),
                  Icons.event_available,
                  Colors.blue,
                ),
                const Divider(height: 24),
                _buildSummaryItem(
                  'В ожидании оплаты',
                  _formatCurrency(summary['pendingPayment']),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                const Divider(height: 24),
                _buildSummaryItem(
                  'Предоплата',
                  _formatCurrency(summary['prepaidAmount']),
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Всего Бронирований',
                    summary['totalBookings'].toString(),
                    Icons.event_available,
                    Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'В ожидании оплаты',
                    _formatCurrency(summary['pendingPayment']),
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Предоплата',
                    _formatCurrency(summary['prepaidAmount']),
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileArenaList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _topArenas.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final arena = _topArenas[index];
        return _buildMobileArenaCard(arena, index + 1);
      },
    );
  }

  Widget _buildMobileArenaCard(Map<String, dynamic> arena, int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arena['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      arena['address'] ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (arena['rating'] > 0)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      arena['rating'].toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Бронирований',
                        '${arena['bookings']}',
                        Colors.blue.shade700,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Прибыль (Комиссия)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(arena['commission']),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      if (arena['ratedCount'] > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${arena['ratedCount']} отзывов',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (arena['ownerName'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Владелец: ${arena['ownerName']}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopArenaTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
            dataRowMinHeight: 70,
            dataRowMaxHeight: 70,
            columnSpacing: 32,
            columns: const [
              DataColumn(
                label: Text(
                  'Ранг',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Название Арены',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Адрес',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Бронирований',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                numeric: true,
              ),

              DataColumn(
                label: Text(
                  'Доход',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Оплата в ожидании',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Предоплата',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Комиссия',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                numeric: true,
              ),
              DataColumn(
                label: Text(
                  'Рейтинг',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
            rows: _topArenas.asMap().entries.map((entry) {
              final index = entry.key;
              final arena = entry.value;
              log(arena.toString() + 'arenaarenaarena');
              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.blue.shade50;
                  }
                  return null;
                }),
                cells: [
                  DataCell(
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _getRankColor(index + 1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          arena['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        if (arena['ownerName'] != null)
                          Text(
                            'Владелец: ${arena['ownerName']}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        arena['address'] ?? '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          arena['bookings'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          'Завершено: ${arena['completedBookings']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  DataCell(
                    Text(
                      _formatCurrency(arena['revenue']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatCurrency(arena['pendingPayment']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatCurrency(arena['prepaidAmount']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      _formatCurrency(arena['commission']),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  DataCell(
                    arena['rating'] > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    arena['rating'].toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${arena['ratedCount']} отзывов',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Нет отзывов',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.orange.shade700; // Bronze
      default:
        return Colors.blue.shade600;
    }
  }

  String _formatNumber(int number) {
    return NumberFormat(
      '#,###',
      'ru_RU',
    ).format(number).replaceAll(',', '\u00A0');
  }

  String _formatCurrency(dynamic amount) {
    // Поддержка как int, так и double
    final value = amount is int ? amount : (amount as double).round();
    return '${NumberFormat('#,###', 'ru_RU').format(value)} ₸';
  }
}
