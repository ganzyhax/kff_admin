import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/arena_helpers.dart';
import 'package:kff_super_admin/app/screens/arena_management/bloc/arena_management_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_action_dialogs.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_edit_screen.dart';

class DesktopArenaTable extends StatelessWidget {
  final List<dynamic> arenas;
  final bool isTablet;

  const DesktopArenaTable({
    Key? key,
    required this.arenas,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 96,
        ),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
          columnSpacing: 24,
          columns: [
            const DataColumn(
              label: Text(
                'НАЗВАНИЕ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            if (!isTablet)
              const DataColumn(
                label: Text(
                  'ВЛАДЕЛЕЦ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            const DataColumn(
              label: Text(
                'СТАТУС',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const DataColumn(
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
          rows: arenas.map<DataRow>((arena) {
            // Extract arena data
            final name = arena['name']?.toString() ?? '';
            final address = arena['address']?.toString() ?? '';
            final status = arena['status']?.toString() ?? '';
            final arenaId = arena['_id']?.toString() ?? '';

            // Extract photos
            final photos = arena['photos'] as List?;
            final firstPhoto = (photos != null && photos.isNotEmpty)
                ? photos[0]?.toString()
                : null;

            // Extract owner
            final owner = arena['owner'] as Map<String, dynamic>?;
            final ownerName = owner?['name']?.toString() ?? 'N/A';
            final ownerPhone = owner?['phone']?.toString() ?? 'N/A';

            return DataRow(
              cells: [
                // Name Cell
                DataCell(_buildNameCell(name, address, firstPhoto, isTablet)),

                // Owner Cell
                if (!isTablet) DataCell(_buildOwnerCell(ownerName, ownerPhone)),

                // Status Cell
                DataCell(buildStatusBadge(status)),

                // Actions Cell
                DataCell(_buildActionsCell(context, arena, arenaId, status)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNameCell(
    String name,
    String address,
    String? photoUrl,
    bool isTablet,
  ) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderImage();
                  },
                )
              : _buildPlaceholderImage(),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isTablet)
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 40,
      height: 40,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 20),
    );
  }

  Widget _buildOwnerCell(String ownerName, String ownerPhone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          ownerName,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          ownerPhone,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionsCell(
    BuildContext context,
    Map<String, dynamic> arena,
    String arenaId,
    String status,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Button
        IconButton(
          onPressed: () => _onEditArena(context, arena),
          icon: const Icon(Icons.edit, size: 18),
          tooltip: 'Редактировать',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(36, 36),
          ),
        ),
        const SizedBox(width: 8),

        // Accept/Reject buttons (only for moderation status)
        if (status == 'moderation') ...[
          IconButton(
            onPressed: () => showAcceptDialog(context, arenaId),
            icon: const Icon(Icons.check, size: 18),
            tooltip: 'Принять',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => showRejectDialog(context, arenaId),
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Отклонить',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Block/Unblock Button (only for active or inactive status)
        if (status == 'active' || status == 'inactive')
          IconButton(
            onPressed: () => showToggleBlockDialog(context, arenaId, status),
            icon: Icon(
              status == 'inactive' ? Icons.lock_open : Icons.block,
              size: 18,
            ),
            tooltip: status == 'inactive' ? 'Разблокировать' : 'Заблокировать',
            style: IconButton.styleFrom(
              backgroundColor: status == 'inactive'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(36, 36),
            ),
          ),
      ],
    );
  }

  void _onEditArena(BuildContext context, Map<String, dynamic> arena) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<ArenaManagementBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ArenaEditPage(arenaId: arena['_id'], existingArena: arena),
          ),
        ),
      ),
    );
  }
}
