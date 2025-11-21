import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/bloc/arena_management_bloc.dart';

/// Shows dialog to accept an arena
void showAcceptDialog(BuildContext context, String arenaId) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Принять арену?'),
      content: const Text('Вы уверены, что хотите активировать эту арену?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<ArenaManagementBloc>().add(
              AcceptArenaEvent(arenaId: arenaId),
            );
            _showSuccessSnackBar(context, 'Арена принята');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Принять'),
        ),
      ],
    ),
  );
}

/// Shows dialog to reject an arena
void showRejectDialog(BuildContext context, String arenaId) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Отклонить арену?'),
      content: const Text('Вы уверены, что хотите отклонить эту арену?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<ArenaManagementBloc>().add(
              RejectArenaEvent(arenaId: arenaId),
            );
            _showErrorSnackBar(context, 'Арена отклонена');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Отклонить'),
        ),
      ],
    ),
  );
}

/// Shows dialog to toggle block/unblock arena
void showToggleBlockDialog(
  BuildContext context,
  String arenaId,
  String currentStatus,
) {
  final isBlocked = currentStatus == 'inactive';

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isBlocked ? 'Разблокировать арену?' : 'Заблокировать арену?'),
      content: Text(
        isBlocked
            ? 'Вы уверены, что хотите разблокировать эту арену?'
            : 'Вы уверены, что хотите заблокировать эту арену?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<ArenaManagementBloc>().add(
              ToggleBlockArenaEvent(arenaId: arenaId, isBlocked: isBlocked),
            );
            _showSuccessSnackBar(
              context,
              isBlocked ? 'Арена разблокирована' : 'Арена заблокирована',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isBlocked
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isBlocked ? 'Разблокировать' : 'Заблокировать'),
        ),
      ],
    ),
  );
}

/// Shows success snack bar
void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

/// Shows error snack bar
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
