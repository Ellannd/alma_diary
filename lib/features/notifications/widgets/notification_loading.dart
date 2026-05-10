import 'package:flutter/material.dart';

class NotificationLoading extends StatelessWidget {
  const NotificationLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}