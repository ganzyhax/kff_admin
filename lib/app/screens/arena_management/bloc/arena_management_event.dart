part of 'arena_management_bloc.dart';

@immutable
abstract class ArenaManagementEvent {
  const ArenaManagementEvent();

  @override
  List<Object?> get props => [];
}

// ==================== 1. LOAD ALL ARENAS ====================
final class ArenaManagementLoad extends ArenaManagementEvent {}

// ==================== 2. SET COMMISSION ====================
final class SetCommissionEvent extends ArenaManagementEvent {
  final double commission;

  const SetCommissionEvent({required this.commission});

  @override
  List<Object?> get props => [commission];
}

// ==================== 3. SET CASHBACK ====================
final class SetCashbackEvent extends ArenaManagementEvent {
  final double cashback;

  const SetCashbackEvent({required this.cashback});

  @override
  List<Object?> get props => [cashback];
}

// ==================== 4. ACCEPT ARENA (Moderation → Active) ====================
final class AcceptArenaEvent extends ArenaManagementEvent {
  final String arenaId;

  const AcceptArenaEvent({required this.arenaId});

  @override
  List<Object?> get props => [arenaId];
}

// ==================== 5. REJECT ARENA (Moderation → Deleted) ====================
final class RejectArenaEvent extends ArenaManagementEvent {
  final String arenaId;

  const RejectArenaEvent({required this.arenaId});

  @override
  List<Object?> get props => [arenaId];
}

// ==================== 6. TOGGLE BLOCK ARENA (Active ↔ Inactive) ====================
final class ToggleBlockArenaEvent extends ArenaManagementEvent {
  final String arenaId;
  final bool
  isBlocked; // true = currently blocked (will unblock), false = currently active (will block)

  const ToggleBlockArenaEvent({required this.arenaId, required this.isBlocked});

  @override
  List<Object?> get props => [arenaId, isBlocked];
}

// ==================== 7. UPDATE ARENA ====================
final class UpdateArenaEvent extends ArenaManagementEvent {
  final String arenaId;
  final String name;
  final String address;
  final String description;
  final String? gisLink;

  // Field parameters
  final double? length;
  final double? width;
  final double? height;
  final int? playersCount;
  final String typeGrass;
  final bool isCovered;

  // Amenities (array of IDs)
  final List<String> amenityIds;

  // Photos and prices
  final List<String> photoUrls;
  final Map<String, Map<String, double?>> prices;

  const UpdateArenaEvent({
    required this.arenaId,
    required this.name,
    required this.address,
    required this.description,
    this.gisLink,
    this.length,
    this.width,
    this.height,
    this.playersCount,
    required this.typeGrass,
    required this.isCovered,
    required this.amenityIds,
    required this.photoUrls,
    required this.prices,
  });

  @override
  List<Object?> get props => [
    arenaId,
    name,
    address,
    description,
    gisLink,
    length,
    width,
    height,
    playersCount,
    typeGrass,
    isCovered,
    amenityIds,
    photoUrls,
    prices,
  ];
}
