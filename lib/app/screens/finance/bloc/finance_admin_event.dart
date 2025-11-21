// lib/screens/finance_admin/bloc/finance_admin_event.dart
part of 'finance_admin_bloc.dart';

abstract class FinanceAdminEvent {}

/// Загрузить финансовые данные
class FinanceAdminLoad extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;
  final String? ownerId;
  final String? status; // 'all', 'completed', 'cancelled', 'partial'
  final int page;
  final int limit;
  final String? sortBy; // 'dateAsc', 'dateDesc', 'amountAsc', 'amountDesc'

  FinanceAdminLoad({
    required this.startDate,
    required this.endDate,
    this.arenaId,
    this.ownerId,
    this.status,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });
}

/// Обновить финансовые данные
class FinanceAdminRefresh extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;
  final String? ownerId;
  final String? status;
  final int page;
  final int limit;
  final String? sortBy;

  FinanceAdminRefresh({
    required this.startDate,
    required this.endDate,
    this.arenaId,
    this.ownerId,
    this.status,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });
}

/// Поиск по транзакциям
class FinanceAdminSearch extends FinanceAdminEvent {
  final String query;

  FinanceAdminSearch(this.query);
}

/// Сортировка транзакций
class FinanceAdminSort extends FinanceAdminEvent {
  final String sortBy; // 'dateAsc', 'dateDesc', 'amountAsc', 'amountDesc'

  FinanceAdminSort(this.sortBy);
}

/// Изменить страницу пагинации
class FinanceAdminChangePage extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;
  final String? ownerId;
  final String? status;
  final int page;
  final int limit;

  FinanceAdminChangePage({
    required this.startDate,
    required this.endDate,
    this.arenaId,
    this.ownerId,
    this.status,
    required this.page,
    this.limit = 20,
  });
}

/// Экспортировать транзакции в CSV
class FinanceAdminExportCSV extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;
  final String? ownerId;

  FinanceAdminExportCSV({
    required this.startDate,
    required this.endDate,
    this.arenaId,
    this.ownerId,
  });
}

/// Фильтр по статусу
class FinanceAdminFilterStatus extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? arenaId;
  final String? ownerId;

  FinanceAdminFilterStatus({
    required this.startDate,
    required this.endDate,
    required this.status,
    this.arenaId,
    this.ownerId,
  });
}

/// Фильтр по арене
class FinanceAdminFilterArena extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String arenaId;
  final String? ownerId;
  final String? status;

  FinanceAdminFilterArena({
    required this.startDate,
    required this.endDate,
    required this.arenaId,
    this.ownerId,
    this.status,
  });
}

/// Фильтр по владельцу
class FinanceAdminFilterOwner extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String ownerId;
  final String? arenaId;
  final String? status;

  FinanceAdminFilterOwner({
    required this.startDate,
    required this.endDate,
    required this.ownerId,
    this.arenaId,
    this.status,
  });
}

/// Изменить диапазон дат
class FinanceAdminChangeDateRange extends FinanceAdminEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? arenaId;
  final String? ownerId;
  final String? status;

  FinanceAdminChangeDateRange({
    required this.startDate,
    required this.endDate,
    this.arenaId,
    this.ownerId,
    this.status,
  });
}
