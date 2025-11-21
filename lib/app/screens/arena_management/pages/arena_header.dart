import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/bloc/arena_management_bloc.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_cashback_card.dart';
import 'package:kff_super_admin/app/screens/arena_management/pages/arena_comission_card.dart';

class ArenaHeader extends StatelessWidget {
  final bool isMobile;
  final double commission;
  final double cashback;

  const ArenaHeader({
    Key? key,
    required this.isMobile,
    required this.commission,
    required this.cashback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Управление Аренами и Владельцами',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (!isMobile)
              Row(
                children: [
                  CommissionCard(commission: commission),
                  const SizedBox(width: 16),
                  CashbackCard(cashback: cashback),
                ],
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: CommissionCard(commission: commission)),
              const SizedBox(width: 12),
              Expanded(child: CashbackCard(cashback: cashback)),
            ],
          ),
        ],
      ],
    );
  }
}
