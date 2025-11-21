import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_super_admin/app/screens/finance/bloc/finance_admin_bloc.dart';

class FinanceAdminPage extends StatefulWidget {
  const FinanceAdminPage({Key? key}) : super(key: key);

  @override
  State<FinanceAdminPage> createState() => _FinanceAdminPageState();
}

class _FinanceAdminPageState extends State<FinanceAdminPage> {
  late DateTime startDate;
  late DateTime endDate;
  String? selectedArenaId;
  String? selectedOwnerId;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    // Default: current month
    startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocProvider(
          create: (context) =>
              FinanceAdminBloc()
                ..add(FinanceAdminLoad(startDate: startDate, endDate: endDate)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: BlocConsumer<FinanceAdminBloc, FinanceAdminState>(
              listener: (context, state) {
                if (state is FinanceAdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is FinanceAdminExportSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is FinanceAdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is FinanceAdminLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildFinanceCard(state),
                    ],
                  );
                }

                if (state is FinanceAdminError) {
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
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<FinanceAdminBloc>().add(
                              FinanceAdminLoad(
                                startDate: startDate,
                                endDate: endDate,
                              ),
                            );
                          },
                          child: const Text('Попробовать снова'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = 36;
        if (constraints.maxWidth < 600) {
          fontSize = 24;
        } else if (constraints.maxWidth < 900) {
          fontSize = 30;
        }

        return Text(
          'Финансы и Отчёты',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        );
      },
    );
  }

  Widget _buildFinanceCard(FinanceAdminLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(state),
          const SizedBox(height: 24),
          _buildSummaryCards(state.summary),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopTable(state.filteredTransactions);
              } else if (constraints.maxWidth > 600) {
                return _buildTabletTable(state.filteredTransactions);
              } else {
                return _buildMobileList(state.filteredTransactions);
              }
            },
          ),
          const SizedBox(height: 24),
          _buildPagination(state),
        ],
      ),
    );
  }

  Widget _buildCardHeader(FinanceAdminLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Text(
            'История транзакций и выплаты за месяц',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<FinanceAdminBloc>().add(
              FinanceAdminExportCSV(
                startDate: startDate,
                endDate: endDate,
                arenaId: selectedArenaId,
                ownerId: selectedOwnerId,
              ),
            );
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Экспорт'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        double childAspectRatio = 2.5;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
          childAspectRatio = 3;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 2;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: childAspectRatio,
          children: [
            _buildSummaryCard(
              title: 'Входящие платежи',
              amount: (summary['incoming'] ?? 0).toInt(),
              subtitle: '${summary['incomingCount'] ?? 0} транзакций',
              color: const Color(0xFF10B981),
              backgroundColor: const Color(0xFFD1FAE5),
              isPositive: true,
            ),
            _buildSummaryCard(
              title:
                  'Комиссия платформы (${summary['commissionPercent'] ?? 0}%)',
              amount: (summary['commission'] ?? 0).toInt(),
              subtitle: 'Удержано',
              color: const Color(0xFFEF4444),
              backgroundColor: const Color(0xFFFEE2E2),
              isPositive: false,
            ),
            _buildSummaryCard(
              title: 'К выплате',
              amount: (summary['toPayout'] ?? 0).toInt(),
              subtitle: 'Выплата 1-го числа',
              color: const Color(0xFF8B5CF6),
              backgroundColor: const Color(0xFFF3E8FF),
              isPositive: null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int amount,
    required String subtitle,
    required Color color,
    required Color backgroundColor,
    bool? isPositive,
  }) {
    String prefix = '';
    if (isPositive == true) prefix = '+';
    if (isPositive == false) prefix = '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [backgroundColor.withOpacity(0.3), backgroundColor],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$prefix${_formatMoney(amount.abs())} ₸',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(List<Map<String, dynamic>> transactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        dataRowHeight: 72,
        columns: const [
          DataColumn(
            label: Text(
              'ДАТА/ВРЕМЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'АРЕНА',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'ВЛАДЕЛЕЦ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'КЛИЕНТ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'СУММА',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'КОМИССИЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'СТАТУС',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        rows: transactions.map((transaction) {
          bool isPayout = transaction['status'] == 'payout';
          return DataRow(
            color: MaterialStateProperty.all(
              isPayout ? const Color(0xFFFEF3C7).withOpacity(0.3) : null,
            ),
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDate(transaction['date']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction['time']?['start'] ?? ''}-${transaction['time']?['end'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  transaction['arena']?['name'] ?? '—',
                  style: const TextStyle(color: Color(0xFF1F2937)),
                ),
              ),
              DataCell(
                Text(
                  transaction['owner']?['name'] ?? '—',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              DataCell(
                Text(
                  transaction['client']?['name'] ?? 'Гость',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              DataCell(
                Text(
                  '${(transaction['amount'] ?? 0) > 0 ? '+' : ''}${_formatMoney((transaction['amount'] ?? 0).toInt())} ₸',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: (transaction['amount'] ?? 0) > 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFF8B5CF6),
                  ),
                ),
              ),
              DataCell(
                Text(
                  (transaction['commissionAmount'] ?? 0) > 0
                      ? '-${_formatMoney((transaction['commissionAmount'] ?? 0).toInt())} ₸'
                      : '—',
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
              DataCell(_buildStatusBadge(transaction['status'] ?? 'completed')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabletTable(List<Map<String, dynamic>> transactions) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        dataRowHeight: 72,
        columns: const [
          DataColumn(
            label: Text(
              'ДАТА/ВРЕМЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'АРЕНА',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'СУММА',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'СТАТУС',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        rows: transactions.map((transaction) {
          bool isPayout = transaction['status'] == 'payout';
          return DataRow(
            color: MaterialStateProperty.all(
              isPayout ? const Color(0xFFFEF3C7).withOpacity(0.3) : null,
            ),
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatDate(transaction['date']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction['time']?['start'] ?? ''}-${transaction['time']?['end'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  transaction['arena']?['name'] ?? '—',
                  style: const TextStyle(color: Color(0xFF1F2937)),
                ),
              ),
              DataCell(
                Text(
                  '${(transaction['amount'] ?? 0) > 0 ? '+' : ''}${_formatMoney((transaction['amount'] ?? 0).toInt())} ₸',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: (transaction['amount'] ?? 0) > 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFF8B5CF6),
                  ),
                ),
              ),
              DataCell(_buildStatusBadge(transaction['status'] ?? 'completed')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> transactions) {
    return Column(
      children: transactions.map((transaction) {
        bool isPayout = transaction['status'] == 'payout';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPayout
                ? const Color(0xFFFEF3C7).withOpacity(0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPayout
                  ? const Color(0xFFF59E0B).withOpacity(0.3)
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(transaction['date']),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${transaction['time']?['start'] ?? ''}-${transaction['time']?['end'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(transaction['status'] ?? 'completed'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['arena']?['name'] ?? '—',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          transaction['client']?['name'] ?? 'Гость',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(transaction['amount'] ?? 0) > 0 ? '+' : ''}${_formatMoney((transaction['amount'] ?? 0).toInt())} ₸',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: (transaction['amount'] ?? 0) > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case 'completed':
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        text = 'Завершено';
        icon = Icons.check_circle;
        break;
      case 'processing':
      case 'partial':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        text = 'Обработка';
        icon = Icons.access_time;
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFEF4444);
        text = 'Отменено';
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        text = 'Неизвестно';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(FinanceAdminLoaded state) {
    final currentPage = state.currentPage;
    final totalPages = state.totalPages;
    final totalCount = state.totalCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Показано ${state.filteredTransactions.length} из $totalCount транзакций',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        Row(
          children: [
            _buildPageButton(
              icon: Icons.chevron_left,
              isEnabled: currentPage > 1,
              onTap: () {
                if (currentPage > 1) {
                  context.read<FinanceAdminBloc>().add(
                    FinanceAdminChangePage(
                      startDate: startDate,
                      endDate: endDate,
                      page: currentPage - 1,
                      arenaId: selectedArenaId,
                      ownerId: selectedOwnerId,
                      status: selectedStatus,
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            for (int i = 1; i <= totalPages && i <= 3; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildPageNumberButton(i, currentPage),
              ),
            _buildPageButton(
              icon: Icons.chevron_right,
              isEnabled: currentPage < totalPages,
              onTap: () {
                if (currentPage < totalPages) {
                  context.read<FinanceAdminBloc>().add(
                    FinanceAdminChangePage(
                      startDate: startDate,
                      endDate: endDate,
                      page: currentPage + 1,
                      arenaId: selectedArenaId,
                      ownerId: selectedOwnerId,
                      status: selectedStatus,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildPageNumberButton(int page, int currentPage) {
    bool isActive = page == currentPage;
    return InkWell(
      onTap: () {
        context.read<FinanceAdminBloc>().add(
          FinanceAdminChangePage(
            startDate: startDate,
            endDate: endDate,
            page: page,
            arenaId: selectedArenaId,
            ownerId: selectedOwnerId,
            status: selectedStatus,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3B82F6) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  String _formatMoney(int amount) {
    final formatter = NumberFormat('#,###', 'ru_RU');
    return formatter.format(amount);
  }

  String _formatDate(dynamic date) {
    try {
      if (date is String) {
        final dateTime = DateTime.parse(date);
        return DateFormat('dd.MM.yyyy').format(dateTime);
      }
      return '—';
    } catch (e) {
      return '—';
    }
  }
}
