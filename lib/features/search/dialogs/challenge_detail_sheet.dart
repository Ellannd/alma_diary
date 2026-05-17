import 'package:alma_diary/features/challenges/screen/challenges_screen.dart';
import 'package:flutter/material.dart';

//todo dont hardcode any colors
class ChallengeDetailSheet {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> entry,
    required String passphrase,
  }) {
    final challenge = entry['challenges'] ?? entry;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HANDLE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// TITLE
              Text(
                challenge['title'] ?? 'Desafío',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              /// CATEGORY
              if (challenge['category'] != null)
                Text(
                  challenge['category'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.7),
                  ),
                ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              Text(
                challenge['description'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: 20),

              /// ACTION
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChallengesPage(
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Ir al desafío'),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}