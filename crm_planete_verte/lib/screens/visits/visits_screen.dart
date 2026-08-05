import 'package:flutter/material.dart';
import '../../models/visit.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_screen_scaffold.dart';
import '../../widgets/app_status_badge.dart';
import 'add_visit_screen.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  List<Visit> visits = [];

  @override
  void initState() {
    super.initState();
    loadVisits();
  }

  Future<void> loadVisits() async {
    final data = await DatabaseService.instance.getVisits();
    setState(() {
      visits = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenScaffold(
      title: 'Visits',
      subtitle: 'Register GPS-based commercial visits and validation status.',
      icon: Icons.location_on_outlined,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVisitScreen()),
          );

          if (result == true) {
            await loadVisits();
          }
        },
        child: const Icon(Icons.add),
      ),
      child: visits.isEmpty
          ? const AppEmptyState(
              icon: Icons.location_on_outlined,
              title: 'No visits found',
              message: 'Add a visit to record GPS validation for a client.',
            )
          : ListView.separated(
              padding: AppSpacing.screenPadding,
              itemCount: visits.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final visit = visits[index];

                return AppMotion.fadeSlide(
                  delay: index * 20,
                  child: Card(
                    child: Padding(
                      padding: AppSpacing.cardPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Visit #${visit.id}',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              AppStatusBadge(
                                label: visit.validationStatus,
                                color: getStatusColor(visit.validationStatus),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Date: ${visit.visitDate.split('T').first} | Time: ${visit.visitTime}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'valid':
        return AppColors.olive;
      case 'invalid':
        return AppColors.red;
      default:
        return AppColors.amber;
    }
  }
}
