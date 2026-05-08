import 'package:flutter/material.dart';


class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("o"),
        ),
        Expanded(child: Divider(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1))),
      ],
    );
  }
}