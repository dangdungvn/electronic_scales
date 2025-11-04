import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/scales/presentation/scale_station_list_screen.dart';
import 'features/pending_weighing/presentation/pending_weighing_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Trạm Cân',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ScaleStationListScreen(),
      routes: {
        '/pending-weighing': (context) => const PendingWeighingListScreen(),
      },
    );
  }
}
