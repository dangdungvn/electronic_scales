import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/scales/presentation/scale_station_list_screen.dart';
import '../../features/pending_weighing/presentation/pending_weighing_list_screen.dart';
import '../../features/home/presentation/home_screen.dart';

part 'app_router.g.dart';

/// GoRouter provider theo chuẩn Agents.md
@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/scales',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/scales',
        name: 'scales',
        builder: (context, state) => const ScaleStationListScreen(),
      ),
      GoRoute(
        path: '/pending-weighing',
        name: 'pending-weighing',
        builder: (context, state) => const PendingWeighingListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Lỗi')),
      body: Center(child: Text('Không tìm thấy trang: ${state.uri.path}')),
    ),
  );
}
