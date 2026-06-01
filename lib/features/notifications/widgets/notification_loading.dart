import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/material.dart';

class NotificationLoading extends StatelessWidget {
  const NotificationLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AlmaLoader(),
    );
  }
}
