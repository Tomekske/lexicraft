import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/navigation_cubit.dart';
import 'practice_view.dart';
import 'settings_view.dart';
import 'home_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;
        final bool showLabels = constraints.maxWidth > 850;

        return BlocBuilder<NavigationCubit, AppView>(
          builder: (context, currentView) {
            return Scaffold(
              appBar: AppBar(
                title: InkWell(
                  onTap: () =>
                      context.read<NavigationCubit>().setView(AppView.home),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('LEXICRAFT',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.orangeAccent)),
                  ),
                ),
                titleSpacing: isMobile ? 8 : 16,
                actions: [
                  if (!isMobile) ...[
                    SegmentedButton<AppView>(
                      segments: [
                        ButtonSegment(
                            value: AppView.home,
                            label: showLabels ? const Text('Home') : null,
                            icon: const Icon(Icons.home)),
                        ButtonSegment(
                            value: AppView.listsAndSettings,
                            label: showLabels
                                ? const Text('Lists & Settings')
                                : null,
                            icon: const Icon(Icons.settings)),
                      ],
                      selected: {currentView == AppView.practice ? AppView.home : currentView},
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
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ],
              ),
              body: _buildBody(currentView),
              bottomNavigationBar: isMobile
                  ? BottomNavigationBar(
                      currentIndex: _viewToIndex(currentView),
                      onTap: (index) {
                        context
                            .read<NavigationCubit>()
                            .setView(_indexToView(index));
                      },
                      selectedItemColor: Colors.orangeAccent,
                      unselectedItemColor: Colors.white54,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          label: 'Settings',
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

  int _viewToIndex(AppView view) {
    switch (view) {
      case AppView.home:
      case AppView.practice:
        return 0;
      case AppView.listsAndSettings:
        return 1;
    }
  }

  AppView _indexToView(int index) {
    switch (index) {
      case 0:
        return AppView.home;
      case 1:
        return AppView.listsAndSettings;
      default:
        return AppView.home;
    }
  }

  Widget _buildBody(AppView currentView) {
    switch (currentView) {
      case AppView.home:
        return const HomeView();
      case AppView.practice:
        return const PracticeView();
      case AppView.listsAndSettings:
        return const SettingsView();
    }
  }
}
