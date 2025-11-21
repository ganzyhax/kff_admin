import 'package:flutter/material.dart';

/// Builds a status badge widget based on arena status
Widget buildStatusBadge(String status) {
  Color bgColor;
  Color textColor;
  String text;

  switch (status) {
    case 'active':
      bgColor = const Color(0xFFD1FAE5);
      textColor = const Color(0xFF065F46);
      text = 'Активна';
      break;
    case 'inactive':
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
      text = 'Заблокирована';
      break;
    case 'moderation':
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFF92400E);
      text = 'Модерация';
      break;
    default:
      bgColor = Colors.grey[200]!;
      textColor = Colors.grey[700]!;
      text = 'Неизвестно';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// Extracts photo URL from arena data
String? extractPhotoUrl(Map<String, dynamic> arena) {
  final photos = arena['photos'] as List?;
  if (photos != null && photos.isNotEmpty) {
    return photos[0]?.toString();
  }
  return null;
}

/// Extracts owner information from arena data
Map<String, String> extractOwnerInfo(Map<String, dynamic> arena) {
  final owner = arena['owner'] as Map<String, dynamic>?;
  return {
    'name': owner?['name']?.toString() ?? 'N/A',
    'phone': owner?['phone']?.toString() ?? 'N/A',
    'email': owner?['email']?.toString() ?? 'N/A',
  };
}
