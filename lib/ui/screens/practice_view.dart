import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/vocab_cubit.dart';
import '../../logic/cubits/practice_cubit.dart';

class PracticeView extends StatelessWidget {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VocabCubit, VocabState>(
      listenWhen: (previous, current) =>
          previous.isLoading && !current.isLoading,
      listener: (context, state) {
        if (state.sets.isNotEmpty) {
          final practiceCubit = context.read<PracticeCubit>();
          if (practiceCubit.state.selectedSetId == null) {
            practiceCubit.updateSettings(selectedSetId: state.sets.first.id);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;
          if (isMobile) {
            return Stack(
              children: [
                _buildMainArea(context, isMobile: true),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => _showControls(context),
                        backgroundColor: Colors.white10,
                        child: const Icon(Icons.tune, color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<VocabCubit, VocabState>(
                        builder: (context, vocabState) {
                          return BlocBuilder<PracticeCubit, PracticeState>(
                            builder: (context, practiceState) {
                              return FloatingActionButton(
                                onPressed: () {
                                  final selectedSetId = practiceState.selectedSetId;
                                  final set = vocabState.sets.firstWhere(
                                    (s) => s.id == selectedSetId,
                                    orElse: () => vocabState.sets.first,
                                  );
                                  context.read<PracticeCubit>().scramble(set);
                                },
                                backgroundColor: Colors.orangeAccent,
                                child: const Icon(Icons.shuffle, color: Colors.black),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              _buildSidebar(context),
              const VerticalDivider(width: 1),
              Expanded(child: _buildMainArea(context)),
            ],
          );
        },
      ),
    );
  }

  void _showControls(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF171717),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        height: MediaQuery.of(context).size.height * 0.4,
        child: SingleChildScrollView(
          child: _buildSidebar(context, isBottomSheet: true),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {bool isBottomSheet = false}) {
    return Container(
      width: isBottomSheet ? double.infinity : 300,
      padding: const EdgeInsets.all(24.0),
      child: BlocBuilder<VocabCubit, VocabState>(
        builder: (context, vocabState) {
          return BlocBuilder<PracticeCubit, PracticeState>(
            builder: (context, practiceState) {
              final sets = vocabState.sets;
              final selectedSetId = practiceState.selectedSetId ??
                  (sets.isNotEmpty ? sets.first.id : null);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Controls', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 32),

                  // Select source column
                  const Text('What should be shown?'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: practiceState.sourceColumn,
                    items: [
                      const DropdownMenuItem(
                          value: 'Symbols', child: Text('Symbols / Enum')),
                      ...vocabState.languages.map((l) =>
                          DropdownMenuItem(value: l, child: Text(l))),
                    ],
                    onChanged: (val) =>
                        context.read<PracticeCubit>().updateSettings(sourceColumn: val),
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  ),

                  const SizedBox(height: 24),

                  // Sequence Length
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sequence Length'),
                      Text(practiceState.sequenceLength.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent)),
                    ],
                  ),
                  Slider(
                    value: practiceState.sequenceLength.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: practiceState.sequenceLength.toString(),
                    onChanged: (val) => context
                        .read<PracticeCubit>()
                        .updateSettings(sequenceLength: val.round()),
                  ),

                  if (!isBottomSheet) const Spacer(),
                  if (isBottomSheet) const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final set = vocabState.sets.firstWhere(
                            (s) => s.id == selectedSetId,
                            orElse: () => vocabState.sets.first);
                        context.read<PracticeCubit>().scramble(set);
                        if (isBottomSheet) Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('SCRAMBLE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainArea(BuildContext context, {bool isMobile = false}) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, vocabState) {
        return BlocBuilder<PracticeCubit, PracticeState>(
          builder: (context, practiceState) {
            final sets = vocabState.sets;
            final selectedSetId = practiceState.selectedSetId;
            final selectedSet = sets.isEmpty
                ? null
                : sets.firstWhere((s) => s.id == selectedSetId,
                    orElse: () => sets.first);

            return Column(
              children: [
                if (selectedSet != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      selectedSet.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 48,
                          vertical: isMobile ? 16 : 32),
                      child: stateWidget(context, practiceState, isMobile),
                    ),
                  ),
                ),
                if (isMobile) const SizedBox(height: 100), // Space for FABs
              ],
            );
          },
        );
      },
    );
  }

  Widget stateWidget(
      BuildContext context, PracticeState state, bool isMobile) {
    if (state.sequence.isEmpty) {
      return Text('Press Scramble to generate a sequence',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      children: state.sequence
          .map((item) =>
              _buildSequenceItem(context, item, state.sourceColumn, isMobile))
          .toList(),
    );
  }

  Widget _buildSequenceItem(
      BuildContext context, String text, String source, bool isMobile) {
    if (source == 'Symbols') {
      return Text(
        text,
        style: TextStyle(fontSize: isMobile ? 36 : 48),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withValues(alpha: 0.1),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w500),
        ),
      );
    }
  }
}
