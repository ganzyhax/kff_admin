import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:kff_super_admin/app/api/api.dart';
import 'package:meta/meta.dart';

part 'users_management_event.dart';
part 'users_management_state.dart';

class UsersManagementBloc
    extends Bloc<UsersManagementEvent, UsersManagementState> {
  UsersManagementBloc() : super(UsersManagementInitial()) {
    var stats;
    var users;
    on<UsersManagementEvent>((event, emit) async {
      // TODO: implement event handler
      if (event is UsersManagementLoad) {
        // Simulate data fetching
        var res = await ApiClient.get('api/dashboard/admin/users/stats');
        log(res.toString());
        if (res['success']) {
          stats = res['data']['data'];
          var resUser = await ApiClient.get('api/dashboard/admin/users');
          if (resUser['success']) {
            users = resUser['data']['data']['users'];
            log(users.toString());
          }
        }

        emit(UsersManagementLoaded(stats: stats, users: users));
      }
    });
  }
}
