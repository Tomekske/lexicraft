import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/navigation_cubit.dart';
import 'practice_view.dart';
import 'settings_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LEXICRAFT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.orangeAccent)),
        actions: [
          BlocBuilder<NavigationCubit, AppView>(
            builder: (context, currentView) {
              return SegmentedButton<AppView>(
                segments: const [
                  ButtonSegment(value: AppView.practice, label: Text('Practice'), icon: Icon(Icons.fitness_center)),
                  ButtonSegment(value: AppView.listsAndSettings, label: Text('Lists & Settings'), icon: Icon(Icons.settings)),
                ],
                selected: {currentView},
                onSelectionChanged: (Set<AppView> newSelection) {
                  context.read<NavigationCubit>().setView(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  selectedBackgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
                  selectedForegroundColor: Colors.orangeAccent,
                ),
              );
            },
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: BlocBuilder<NavigationCubit, AppView>(
        builder: (context, currentView) {
          switch (currentView) {
            case AppView.practice:
              return const PracticeView();
            case AppView.listsAndSettings:
              return const SettingsView();
          }
        },
      ),
    );
  }
}
