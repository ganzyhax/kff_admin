// lib/screens/finance_admin/bloc/finance_admin_state.dart
part of 'finance_admin_bloc.dart';

abstract class FinanceAdminState {}

class FinanceAdminInitial extends FinanceAdminState {}

class FinanceAdminLoading extends FinanceAdminState {}

class FinanceAdminLoaded extends FinanceAdminState {
  final List<Map<String, dynamic>> transactions;
  final Map<String, dynamic> summary;
  final Map<String, dynamic> pagination;
  final String searchQuery;
  final String sortBy;

  FinanceAdminLoaded({
    required this.transactions,
    required this.summary,
    required this.pagination,
    this.searchQuery = '',
    this.sortBy = 'dateDesc',
  });

  List<Map<String, dynamic>> get filteredTransactions {
    if (searchQuery.isEmpty) return transactions;

    return transactions.where((transaction) {
      final query = searchQuery.toLowerCase();

      // Client info
      final clientName = (transaction['client']?['name'] ?? '')
          .toString()
          .toLowerCase();
      final clientPhone = (transaction['client']?['phone'] ?? '').toString();

      // Arena info
      final arenaName = (transaction['arena']?['name'] ?? '')
          .toString()
          .toLowerCase();

      // Owner info
      final ownerName = (transaction['owner']?['name'] ?? '')
          .toString()
          .toLowerCase();

      return clientName.contains(query) ||
          arenaName.contains(query) ||
          ownerName.contains(query) ||
          clientPhone.contains(query);
    }).toList();
  }

  int get totalPages => pagination['pages'] ?? 1;
  int get currentPage => pagination['page'] ?? 1;
  int get totalCount => pagination['total'] ?? 0;
}

class FinanceAdminError extends FinanceAdminState {
  final String message;

  FinanceAdminError(this.message);
}

class FinanceAdminExporting extends FinanceAdminState {}

class FinanceAdminExportSuccess extends FinanceAdminState {
  final String message;

  FinanceAdminExportSuccess(this.message);
}
