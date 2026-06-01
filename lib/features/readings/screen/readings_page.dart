import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/state/readings/readings_controller.dart';
import '../widgets/reading_card.dart';

class ReadingsPage extends ConsumerStatefulWidget {
  const ReadingsPage({super.key});

  @override
  ConsumerState<ReadingsPage> createState() => _ReadingsPageState();
}

class _ReadingsPageState extends ConsumerState<ReadingsPage> {
  final Set<String> _helped = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      ref.read(readingsControllerProvider.notifier).setUser(user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isLoading = ref.watch(readingsControllerProvider.select((s) => s.isLoading));
    final readings = ref.watch(readingsControllerProvider.select((s) => s.readings));

    final controller = ref.read(readingsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      appBar: AppBar(
        backgroundColor: AlmaColors.background(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AlmaColors.textPrimary(isDark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Lecturas recomendadas',
          style: AlmaTypography.h3(isDark, context).copyWith(fontSize: AlmaSpacing.r(context, AlmaSpacing.lg)),
        ),
      ),
      body: isLoading
          ? Center(
              child: AlmaLoader(
                color: AlmaColors.accent(isDark),
              ),
            )
          : readings.isEmpty
              ? Center(
                  child: Text(
                    'No hay lecturas disponibles',
                    style: AlmaTypography.bodyMedium(isDark, context).copyWith(
                      color: AlmaColors.textMuted(isDark),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: AlmaSpacing.screenH(context)+AlmaSpacing.sm,
                    vertical: AlmaSpacing.r(context, AlmaSpacing.lg),
                  ),
                  itemCount: readings.length,
                  separatorBuilder: (_, _) => SizedBox(
                    height: AlmaSpacing.r(context, AlmaSpacing.lg),
                  ),
                  itemBuilder: (context, i) {
                    final rec = readings[i];
                    return ReadingCard(
                      rec: rec,
                      saved: controller.isSaved(rec['id']),
                      helped: _helped.contains(rec['id']),
                      onSave: () => controller.toggleSave(rec['id']),
                      onHelped: () => setState(() => _helped.add(rec['id'])),
                    );
                  },
                ),
    );
  }
}
