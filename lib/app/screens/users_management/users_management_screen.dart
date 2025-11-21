import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/users_management/bloc/users_management_bloc.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({Key? key}) : super(key: key);

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocProvider(
          create: (context) =>
              UsersManagementBloc()..add(UsersManagementLoad()),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: BlocBuilder<UsersManagementBloc, UsersManagementState>(
              builder: (context, state) {
                if (state is UsersManagementLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double fontSize = 36;
                          if (constraints.maxWidth < 600) {
                            fontSize = 24;
                          } else if (constraints.maxWidth < 900) {
                            fontSize = 30;
                          }

                          return Text(
                            'Управление Пользователями',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildStatisticsCards(state.stats),
                      const SizedBox(height: 24),

                      // Users table
                      Container(
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
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double fontSize = 24;
                                if (constraints.maxWidth < 600) {
                                  fontSize = 18;
                                } else if (constraints.maxWidth < 900) {
                                  fontSize = 20;
                                }

                                return Text(
                                  'Полный список пользователей',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 900) {
                                  return _buildDesktopTable(state.users);
                                } else if (constraints.maxWidth > 600) {
                                  return _buildTabletTable(state.users);
                                } else {
                                  return _buildMobileList(state.users);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        double childAspectRatio = 4.5;

        if (constraints.maxWidth < 600) {
          crossAxisCount = 1;
          childAspectRatio = 5;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 3.5;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              title: 'Всего игроков',
              value: _formatNumber(stats['totalPlayers'] ?? 0),
              icon: Icons.people_rounded,
              color: const Color(0xFF3B82F6),
              backgroundColor: const Color(0xFFDBEAFE),
            ),
            _buildStatCard(
              title: 'Активных (24ч)',
              value: _formatNumber(stats['activePlayers24h'] ?? 0),
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF10B981),
              backgroundColor: const Color(0xFFD1FAE5),
            ),
            _buildStatCard(
              title: 'Заблокировано',
              value: (stats['blockedUsers'] ?? 0).toString(),
              icon: Icons.block_rounded,
              color: const Color(0xFFEF4444),
              backgroundColor: const Color(0xFFFEE2E2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, backgroundColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: backgroundColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                    height: 1.2,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Desktop table view
  Widget _buildDesktopTable(users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        dataRowHeight: 72,
        columns: const [
          DataColumn(
            label: Text(
              'ПОЛЬЗОВАТЕЛЬ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'РОЛЬ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'ПОСЛЕДНЯЯ АКТИВНОСТЬ',
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
          DataColumn(
            label: Text(
              'ДЕЙСТВИЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        rows: users.map<DataRow>((user) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user['name'] ?? 'Без имени',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(_buildRoleBadge(user['role'] ?? '')),
              DataCell(
                Text(
                  user['lastActivity'] ?? 'Никогда',
                  style: const TextStyle(color: Color(0xFF6B7280)),
                ),
              ),
              DataCell(_buildStatusBadge(user['status'] ?? 'active')),
              DataCell(_buildActionButtons(user['id'] ?? '')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Tablet table view (hide last activity column)
  Widget _buildTabletTable(users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
        dataRowHeight: 72,
        columns: const [
          DataColumn(
            label: Text(
              'ПОЛЬЗОВАТЕЛЬ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'РОЛЬ',
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
          DataColumn(
            label: Text(
              'ДЕЙСТВИЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
        rows: users.map<DataRow>((user) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user['name'] ?? 'Без имени',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(_buildRoleBadge(user['role'] ?? '')),
              DataCell(_buildStatusBadge(user['status'] ?? 'active')),
              DataCell(_buildActionButtons(user['id'] ?? '')),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Mobile list view
  Widget _buildMobileList(users) {
    return Column(
      children: users.map<Widget>((user) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
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
                          user['name'] ?? 'Без имени',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['email'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(user['id'] ?? ''),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildRoleBadge(user['role'] ?? ''),
                  const SizedBox(width: 8),
                  _buildStatusBadge(user['status'] ?? 'active'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;
    String text;

    // Приводим к нижнему регистру для сравнения
    String roleLower = role.toLowerCase();

    switch (roleLower) {
      case 'user':
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF1D4ED8);
        text = 'Игрок';
        break;
      case 'owner':
        backgroundColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF7C3AED);
        text = 'Владелец';
        break;
      case 'superadmin':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        text = 'Админ';
        break;
      default:
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        text = role.isNotEmpty ? role : 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        text = 'Активен';
        break;
      case 'blocked':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        text = 'Заблокир.';
        break;
      case 'inactive':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        text = 'Неактивен';
        break;
      default:
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF6B7280);
        text = 'Неизвестно';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons(String userId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _onLockUser(userId),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.lock, color: Colors.white, size: 14),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _onViewUserInfo(userId),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.info, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  void _onLockUser(String userId) {
    // Implement lock/unlock user logic
    print('Lock user: $userId');
  }

  void _onViewUserInfo(String userId) {
    // Implement view user info logic
    print('View user info: $userId');
  }
}
