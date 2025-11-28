import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../domain/scale_station.dart';
import '../presentation/add_edit_station_screen.dart';

/// Widget card hiển thị thông tin trạm cân trong list
class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.index,
    required this.onTest,
  });

  final ScaleStation station;
  final int index;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    // Gradient colors cho mỗi card
    final gradients = [
      [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
      [const Color(0xFF9C27B0), const Color(0xFFBA68C8)],
      [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
      [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      [const Color(0xFFFF9800), const Color(0xFFFFB74D)],
    ];

    final gradient = gradients[index % gradients.length];

    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTest,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                gradient[0].withOpacity(0.1),
                gradient[1].withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon với gradient
              Hero(
                tag: 'station_${station.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: gradient[0].withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.weight_1,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      station.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Iconsax.global, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${station.ip}:${station.port}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Edit button
              IconButton(
                onPressed: () =>
                    showAddEditStationSheet(context: context, station: station),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: gradient[0].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Iconsax.edit, color: gradient[0], size: 18),
                ),
                tooltip: 'Sửa trạm cân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
