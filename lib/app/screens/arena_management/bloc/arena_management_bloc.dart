import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:kff_super_admin/app/api/api.dart';

import 'package:meta/meta.dart';
// Import your ApiClient
// import 'package:kff_super_admin/core/api/api_client.dart';

part 'arena_management_event.dart';
part 'arena_management_state.dart';

class ArenaManagementBloc
    extends Bloc<ArenaManagementEvent, ArenaManagementState> {
  ArenaManagementBloc() : super(ArenaManagementInitial()) {
    on<ArenaManagementLoad>(_onLoad);
    on<SetCommissionEvent>(_onSetCommission);
    on<SetCashbackEvent>(_onSetCashback);
    on<AcceptArenaEvent>(_onAcceptArena);
    on<RejectArenaEvent>(_onRejectArena);
    on<ToggleBlockArenaEvent>(_onToggleBlockArena);
    on<UpdateArenaEvent>(_onUpdateArena);
  }

  // Load all arenas
  Future<void> _onLoad(
    ArenaManagementLoad event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      emit(ArenaManagementLoading());

      // Dummy data for testing - REMOVE THIS
      var response = await ApiClient.get('api/arenas/admin/all');
      log('Load arenas response: $response');
      if (response['success']) {
        final arenas = response['data']['data'];
        var res = await ApiClient.get('api/settings');
        int comission = 0;
        int cashback = 0;
        if (res['success']) {
          log(res['data']['data'].toString());
          for (var i = 0; i < res['data']['data'].length; i++) {
            if (res['data']['data'][i]['key'] == 'CASHBACK_PERCENTAGE') {
              cashback = res['data']['data'][i]['value'];
            }
            if (res['data']['data'][i]['key'] == 'COMMISSION_PERCENTAGE') {
              comission = res['data']['data'][i]['value'];
            }
          }
        }
        var stats = await ApiClient.get('api/arenas/admin/stats');
        if (stats['success']) {
          log(stats.toString());
          stats = stats['data']['data'];
        }
        emit(
          ArenaManagementLoaded(
            arenas: arenas,
            stats: stats,
            commission: comission.toDouble(), // Default or fetch from backend
            cashback: cashback.toDouble(), // Default or fetch from backend
          ),
        );
      } else {
        emit(
          ArenaManagementError(
            message: response['message']?.toString() ?? 'Failed to load arenas',
          ),
        );
      }
    } catch (e) {
      log('Error loading arenas: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Set commission
  Future<void> _onSetCommission(
    SetCommissionEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ArenaManagementLoaded) return;

      // TODO: Save commission to backend
      await ApiClient.put('api/settings/COMMISSION_PERCENTAGE', {
        'value': event.commission,
      });

      emit(currentState.copyWith(commission: event.commission));
    } catch (e) {
      log('Error setting commission: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Set cashback
  Future<void> _onSetCashback(
    SetCashbackEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! ArenaManagementLoaded) return;

      // TODO: Save cashback to backend
      await ApiClient.put('api/settings/CASHBACK_PERCENTAGE', {
        'value': event.cashback,
      });

      emit(currentState.copyWith(cashback: event.cashback));
    } catch (e) {
      log('Error setting cashback: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Accept arena (moderation -> active)
  Future<void> _onAcceptArena(
    AcceptArenaEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      // TODO: Update arena status to active
      await ApiClient.put('api/arenas/admin/${event.arenaId}/status', {
        'status': 'active',
      });

      // Reload arenas
      add(ArenaManagementLoad());
    } catch (e) {
      log('Error accepting arena: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Reject arena (moderation -> rejected)
  Future<void> _onRejectArena(
    RejectArenaEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      // TODO: Update arena status to rejected or delete
      // await ApiClient.delete('api/arenas/${event.arenaId}');
      // OR
      await ApiClient.put('api/arenas/admin/${event.arenaId}/status', {
        'status': 'rejected',
      });

      // Reload arenas
      add(ArenaManagementLoad());
    } catch (e) {
      log('Error rejecting arena: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Toggle block arena (active <-> inactive)
  Future<void> _onToggleBlockArena(
    ToggleBlockArenaEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      final newStatus = event.isBlocked ? 'active' : 'inactive';

      // TODO: Update arena status
      await ApiClient.put('api/arenas/admin/${event.arenaId}/status', {
        'status': newStatus,
      });

      // Reload arenas
      add(ArenaManagementLoad());
    } catch (e) {
      log('Error toggling block arena: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }

  // Update arena
  Future<void> _onUpdateArena(
    UpdateArenaEvent event,
    Emitter<ArenaManagementState> emit,
  ) async {
    try {
      emit(const ArenaUpdating());

      final body = {
        'name': event.name,
        'address': event.address,
        'description': event.description,
        'gisLink': event.gisLink,
        'length': event.length,
        'width': event.width,
        'height': event.height,
        'isCovered': event.isCovered,
        'typeGrass': event.typeGrass,
        'playersCount': event.playersCount,
        'amenities': {
          'hasShower': event.amenityIds.contains('shower'),
          'hasLockerRoom': event.amenityIds.contains('lockerRoom'),
          'hasStands': event.amenityIds.contains('stands'),
          'hasLighting': event.amenityIds.contains('lighting'),
          'hasFreeParking': event.amenityIds.contains('freeParking'),
        },
        'photos': event.photoUrls,
        'prices': event.prices,
      };

      log('Updating arena: $body');

      // TODO: Replace with your actual API call
      var res = await ApiClient.put('api/arenas/admin/${event.arenaId}', body);

      if (res['success'] == true) {
        emit(const ArenaUpdated(message: 'Арена обновлена!'));
        // Reload arenas
        add(ArenaManagementLoad());
      } else {
        emit(
          ArenaManagementError(
            message: res['message']?.toString() ?? 'Ошибка обновления',
          ),
        );
      }
    } catch (e) {
      log('Error updating arena: $e');
      emit(ArenaManagementError(message: e.toString()));
    }
  }
}
