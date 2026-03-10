import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/vocab_cubit.dart';
import '../../logic/cubits/practice_cubit.dart';
import '../../logic/cubits/navigation_cubit.dart';
import '../../data/models/vocab_models.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, state) {
        if (state.sets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list_alt, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                const Text('No word lists found', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<NavigationCubit>().setView(AppView.listsAndSettings),
                  child: const Text('Create a List'),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 700;
            if (isMobile) {
              return _buildListView(context, state.sets);
            } else {
              return _buildTileView(context, state.sets);
            }
          },
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, List<VocabSet> sets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(set.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text('${set.items.length} items'),
            trailing: const Icon(Icons.chevron_right, color: Colors.orangeAccent),
            onTap: () => _selectAndRedirect(context, set),
          ),
        );
      },
    );
  }

  Widget _buildTileView(BuildContext context, List<VocabSet> sets) {
    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 1.5,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return InkWell(
          onTap: () => _selectAndRedirect(context, set),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orangeAccent.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center, color: Colors.orangeAccent, size: 32),
                const SizedBox(height: 12),
                Text(
                  set.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text('${set.items.length} items', style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectAndRedirect(BuildContext context, VocabSet set) {
    context.read<PracticeCubit>().updateSettings(selectedSetId: set.id);
    context.read<NavigationCubit>().setView(AppView.practice);
  }
}
