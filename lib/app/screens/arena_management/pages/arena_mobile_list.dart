import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/arena_helpers.dart';
import 'package:kff_super_admin/app/screens/arena_management/bloc/arena_management_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_action_dialogs.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_edit_screen.dart';

class MobileArenaList extends StatelessWidget {
  final List<dynamic> arenas;

  const MobileArenaList({Key? key, required this.arenas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: arenas.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final arena = arenas[index];
        return _buildArenaCard(context, arena);
      },
    );
  }

  Widget _buildArenaCard(BuildContext context, Map<String, dynamic> arena) {
    final status = arena['status']?.toString() ?? '';
    final arenaId = arena['_id']?.toString() ?? '';
    final name = arena['name']?.toString() ?? '';
    final address = arena['address']?.toString() ?? '';

    // Extract photos
    final photos = arena['photos'] as List?;
    final firstPhoto = (photos != null && photos.isNotEmpty)
        ? photos[0]?.toString()
        : null;

    // Extract owner
    final owner = arena['owner'] as Map<String, dynamic>?;
    final ownerName = owner?['name']?.toString() ?? 'N/A';
    final ownerPhone = owner?['phone']?.toString() ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: firstPhoto != null
                    ? Image.network(
                        firstPhoto,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$ownerName • $ownerPhone',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    buildStatusBadge(status),
                  ],
                ),
              ),
            ],
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildActionButtons(context, arena, arenaId, status),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Map<String, dynamic> arena,
    String arenaId,
    String status,
  ) {
    if (status == 'moderation') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showAcceptDialog(context, arenaId),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Принять'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showRejectDialog(context, arenaId),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Отклонить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _onEditArena(context, arena),
            icon: const Icon(Icons.edit, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      );
    }

    // For active or inactive status
    if (status == 'active' || status == 'inactive') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => showToggleBlockDialog(context, arenaId, status),
              icon: Icon(
                status == 'inactive' ? Icons.lock_open : Icons.block,
                size: 18,
              ),
              label: Text(
                status == 'inactive' ? 'Разблокировать' : 'Заблокировать',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'inactive'
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _onEditArena(context, arena),
            icon: const Icon(Icons.edit, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      );
    }

    // Default: only edit button
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () => _onEditArena(context, arena),
        icon: const Icon(Icons.edit, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
      ),
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
