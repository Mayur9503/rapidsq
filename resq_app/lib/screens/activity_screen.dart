import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../state/app_state_controller.dart';
import '../models/activity_record.dart';

class ActivityScreen extends StatelessWidget {
  final AppStateController controller;

  const ActivityScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final history = controller.activityHistory;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Emergency Activity Log', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final record = history[index];
            final isCompleted = record.status == ActivityStatus.completed;

            return InkWell(
              onTap: () {
                _showDetails(context, record);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.id,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.tertiaryFixed.withValues(alpha: 0.5)
                                : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCompleted ? 'COMPLETED' : 'CANCELLED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isCompleted ? AppColors.tertiary : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      record.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.subtitle,
                      style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  record.location,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          record.timeFormatted,
                          style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, ActivityRecord record) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dispatch ${record.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                Text(record.timeFormatted, style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(record.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text(record.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            const Divider(height: 24),
            _buildDetailRow('Assigned Unit', '${record.vehicleNumber} (Driver: ${record.driverName})'),
            const SizedBox(height: 6),
            _buildDetailRow('Pickup Point', record.location),
            const SizedBox(height: 6),
            _buildDetailRow('Response Time', '${record.responseTimeMinutes} Minutes from signal trigger'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: const Text('CLOSE SUMMARY'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondary))),
        Expanded(child: Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }
}
