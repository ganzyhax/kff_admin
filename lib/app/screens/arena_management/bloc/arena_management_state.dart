part of 'arena_management_bloc.dart';

@immutable
abstract class ArenaManagementState {
  const ArenaManagementState();

  @override
  List<Object?> get props => [];
}

// Initial state
final class ArenaManagementInitial extends ArenaManagementState {}

// Loading state
final class ArenaManagementLoading extends ArenaManagementState {}

// Loaded state with arenas, commission, and cashback
final class ArenaManagementLoaded extends ArenaManagementState {
  final List<dynamic> arenas;
  final double? commission;
  final double? cashback;
  final stats;
  const ArenaManagementLoaded({
    required this.arenas,
    this.commission,
    this.cashback,
    this.stats,
  });

  @override
  List<Object?> get props => [arenas, commission, cashback, stats];

  // Copy with method for easy state updates
  ArenaManagementLoaded copyWith({
    List<dynamic>? arenas,
    double? commission,
    double? cashback,
    stats,
  }) {
    return ArenaManagementLoaded(
      arenas: arenas ?? this.arenas,
      commission: commission ?? this.commission,
      cashback: cashback ?? this.cashback,
      stats: stats ?? this.stats,
    );
  }
}

// Error state
final class ArenaManagementError extends ArenaManagementState {
  final String message;

  const ArenaManagementError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Success state
final class ArenaManagementSuccess extends ArenaManagementState {
  final String message;

  const ArenaManagementSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

// Arena updating state
final class ArenaUpdating extends ArenaManagementState {
  const ArenaUpdating();
}

// Arena updated state
final class ArenaUpdated extends ArenaManagementState {
  final String message;

  const ArenaUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}
