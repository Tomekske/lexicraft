import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/navigation_cubit.dart';
import 'practice_view.dart';
import 'settings_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return BlocBuilder<NavigationCubit, AppView>(
          builder: (context, currentView) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('LEXICRAFT',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.orangeAccent)),
                actions: [
                  if (!isMobile) ...[
                    SegmentedButton<AppView>(
                      segments: const [
                        ButtonSegment(
                            value: AppView.practice,
                            label: Text('Practice'),
                            icon: Icon(Icons.fitness_center)),
                        ButtonSegment(
                            value: AppView.listsAndSettings,
                            label: Text('Lists & Settings'),
                            icon: Icon(Icons.settings)),
                      ],
                      selected: {currentView},
                      onSelectionChanged: (Set<AppView> newSelection) {
                        context
                            .read<NavigationCubit>()
                            .setView(newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        selectedBackgroundColor:
                            Colors.orangeAccent.withValues(alpha: 0.2),
                        selectedForegroundColor: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ],
              ),
              body: _buildBody(currentView),
              bottomNavigationBar: isMobile
                  ? BottomNavigationBar(
                      currentIndex: currentView == AppView.practice ? 0 : 1,
                      onTap: (index) {
                        context.read<NavigationCubit>().setView(
                            index == 0 ? AppView.practice : AppView.listsAndSettings);
                      },
                      selectedItemColor: Colors.orangeAccent,
                      unselectedItemColor: Colors.white54,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.fitness_center),
                          label: 'Practice',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          label: 'Lists & Settings',
                        ),
                      ],
                    )
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildBody(AppView currentView) {
    switch (currentView) {
      case AppView.practice:
        return const PracticeView();
      case AppView.listsAndSettings:
        return const SettingsView();
    }
  }
}
