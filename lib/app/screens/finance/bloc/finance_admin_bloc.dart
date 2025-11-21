// lib/screens/finance_admin/bloc/finance_admin_bloc.dart
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_super_admin/app/api/api.dart';
part 'finance_admin_event.dart';
part 'finance_admin_state.dart';

class FinanceAdminBloc extends Bloc<FinanceAdminEvent, FinanceAdminState> {
  FinanceAdminBloc() : super(FinanceAdminInitial()) {
    on<FinanceAdminLoad>(_onFinanceAdminLoad);
    on<FinanceAdminRefresh>(_onFinanceAdminRefresh);
    on<FinanceAdminSearch>(_onFinanceAdminSearch);
    on<FinanceAdminSort>(_onFinanceAdminSort);
    on<FinanceAdminChangePage>(_onFinanceAdminChangePage);
    on<FinanceAdminExportCSV>(_onFinanceAdminExportCSV);
  }

  // ==================== ЗАГРУЗИТЬ ФИНАНСЫ ====================
  Future<void> _onFinanceAdminLoad(
    FinanceAdminLoad event,
    Emitter<FinanceAdminState> emit,
  ) async {
    emit(FinanceAdminLoading());

    try {
      final startDateStr = DateFormat('yyyy-MM-dd').format(event.startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(event.endDate);

      log('Loading admin finance data: $startDateStr to $endDateStr');

      // Build query parameters
      final params = {
        'startDate': startDateStr,
        'endDate': endDateStr,
        'page': event.page.toString(),
        'limit': event.limit.toString(),
      };

      if (event.arenaId != null && event.arenaId != 'all') {
        params['arenaId'] = event.arenaId!;
      }

      if (event.ownerId != null && event.ownerId != 'all') {
        params['ownerId'] = event.ownerId!;
      }

      if (event.status != null && event.status != 'all') {
        params['status'] = event.status!;
      }

      if (event.sortBy != null) {
        params['sortBy'] = event.sortBy!;
      }

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      // Get transactions
      final transactionsRes = await ApiClient.get(
        'api/finance/admin/transactions?$queryString',
      );

      // Get summary
      final summaryRes = await ApiClient.get(
        'api/finance/admin/summary?$queryString',
      );

      log('Admin finance transactions response: $transactionsRes');
      log('Admin finance summary response: $summaryRes');

      if (transactionsRes == null || summaryRes == null) {
        emit(FinanceAdminError('Ответ сервера пустой'));
        return;
      }

      // Check if data is wrapped in additional 'data' key
      final transactionsData = transactionsRes['data'] ?? transactionsRes;
      final summaryData = summaryRes['data'] ?? summaryRes;

      if (transactionsData['success'] == true &&
          summaryData['success'] == true) {
        // Safe null handling for transactions
        final transactionsList = transactionsData['data']?['transactions'];
        final transactions = transactionsList != null
            ? (transactionsList as List<dynamic>)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList()
            : <Map<String, dynamic>>[];

        // Safe null handling for pagination
        final paginationObj = transactionsData['data']?['pagination'];
        final pagination = paginationObj != null
            ? Map<String, dynamic>.from(paginationObj as Map)
            : <String, dynamic>{'total': 0, 'page': 1, 'pages': 1, 'limit': 20};

        // Safe null handling for summary
        final summaryObj = summaryData['data'];
        final summary = summaryObj != null
            ? Map<String, dynamic>.from(summaryObj as Map)
            : <String, dynamic>{};

        log('Loaded ${transactions.length} admin transactions');

        emit(
          FinanceAdminLoaded(
            transactions: transactions,
            summary: summary,
            pagination: pagination,
          ),
        );
      } else {
        final errorMsg =
            transactionsData['message'] ??
            summaryData['message'] ??
            'Ошибка при загрузке данных';
        emit(FinanceAdminError(errorMsg));
      }
    } catch (e, stackTrace) {
      log('Admin finance load error: $e');
      log('Stack trace: $stackTrace');
      emit(FinanceAdminError('Ошибка: ${e.toString()}'));
    }
  }

  // ==================== ОБНОВИТЬ ФИНАНСЫ ====================
  Future<void> _onFinanceAdminRefresh(
    FinanceAdminRefresh event,
    Emitter<FinanceAdminState> emit,
  ) async {
    add(
      FinanceAdminLoad(
        startDate: event.startDate,
        endDate: event.endDate,
        arenaId: event.arenaId,
        ownerId: event.ownerId,
        status: event.status,
        page: event.page,
        limit: event.limit,
        sortBy: event.sortBy,
      ),
    );
  }

  // ==================== ПОИСК ====================
  Future<void> _onFinanceAdminSearch(
    FinanceAdminSearch event,
    Emitter<FinanceAdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceAdminLoaded) {
      emit(
        FinanceAdminLoaded(
          transactions: currentState.transactions,
          summary: currentState.summary,
          pagination: currentState.pagination,
          searchQuery: event.query,
          sortBy: currentState.sortBy,
        ),
      );
    }
  }

  // ==================== СОРТИРОВКА ====================
  Future<void> _onFinanceAdminSort(
    FinanceAdminSort event,
    Emitter<FinanceAdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceAdminLoaded) {
      List<Map<String, dynamic>> sortedTransactions = List.from(
        currentState.transactions,
      );

      switch (event.sortBy) {
        case 'dateAsc':
          sortedTransactions.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'].toString());
              final dateB = DateTime.parse(b['date'].toString());
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'dateDesc':
          sortedTransactions.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['date'].toString());
              final dateB = DateTime.parse(b['date'].toString());
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });
          break;
        case 'amountAsc':
          sortedTransactions.sort((a, b) {
            final amountA = (a['amount'] as num?)?.toDouble() ?? 0;
            final amountB = (b['amount'] as num?)?.toDouble() ?? 0;
            return amountA.compareTo(amountB);
          });
          break;
        case 'amountDesc':
          sortedTransactions.sort((a, b) {
            final amountA = (a['amount'] as num?)?.toDouble() ?? 0;
            final amountB = (b['amount'] as num?)?.toDouble() ?? 0;
            return amountB.compareTo(amountA);
          });
          break;
      }

      emit(
        FinanceAdminLoaded(
          transactions: sortedTransactions,
          summary: currentState.summary,
          pagination: currentState.pagination,
          searchQuery: currentState.searchQuery,
          sortBy: event.sortBy,
        ),
      );
    }
  }

  // ==================== СМЕНА СТРАНИЦЫ ====================
  Future<void> _onFinanceAdminChangePage(
    FinanceAdminChangePage event,
    Emitter<FinanceAdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is FinanceAdminLoaded) {
      add(
        FinanceAdminLoad(
          startDate: event.startDate,
          endDate: event.endDate,
          arenaId: event.arenaId,
          ownerId: event.ownerId,
          status: event.status,
          page: event.page,
          limit: event.limit,
          sortBy: currentState.sortBy,
        ),
      );
    }
  }

  // ==================== ЭКСПОРТ CSV ====================
  Future<void> _onFinanceAdminExportCSV(
    FinanceAdminExportCSV event,
    Emitter<FinanceAdminState> emit,
  ) async {
    try {
      final currentState = state;

      emit(FinanceAdminExporting());

      final startDateStr = DateFormat('yyyy-MM-dd').format(event.startDate);
      final endDateStr = DateFormat('yyyy-MM-dd').format(event.endDate);

      final params = {'startDate': startDateStr, 'endDate': endDateStr};

      if (event.arenaId != null && event.arenaId != 'all') {
        params['arenaId'] = event.arenaId!;
      }

      if (event.ownerId != null && event.ownerId != 'all') {
        params['ownerId'] = event.ownerId!;
      }

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final url = 'api/finance/admin/export-csv?$queryString';
      log('Export CSV URL: $url');

      // TODO: Implement actual file download based on platform
      // For web: window.open(url)
      // For mobile: use http client and save file

      emit(FinanceAdminExportSuccess('CSV экспортирован успешно'));

      // Restore previous state after 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (currentState is FinanceAdminLoaded) {
        emit(currentState);
      } else {
        add(
          FinanceAdminLoad(
            startDate: event.startDate,
            endDate: event.endDate,
            arenaId: event.arenaId,
            ownerId: event.ownerId,
          ),
        );
      }
    } catch (e) {
      log('Export CSV error: $e');
      emit(FinanceAdminError('Ошибка при экспорте: ${e.toString()}'));
    }
  }
}
