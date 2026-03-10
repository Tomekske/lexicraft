import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/vocab_cubit.dart';
import '../../logic/cubits/practice_cubit.dart';

class PracticeView extends StatelessWidget {
  const PracticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VocabCubit, VocabState>(
      listenWhen: (previous, current) => previous.isLoading && !current.isLoading,
      listener: (context, state) {
        if (state.sets.isNotEmpty) {
          final practiceCubit = context.read<PracticeCubit>();
          if (practiceCubit.state.selectedSetId == null) {
            practiceCubit.updateSettings(selectedSetId: state.sets.first.id);
          }
        }
      },
      child: Row(
        children: [
          _buildSidebar(context),
          const VerticalDivider(width: 1),
          Expanded(child: _buildMainArea(context)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24.0),
      child: BlocBuilder<VocabCubit, VocabState>(
        builder: (context, vocabState) {
          return BlocBuilder<PracticeCubit, PracticeState>(
            builder: (context, practiceState) {
              final sets = vocabState.sets;
              final selectedSetId = practiceState.selectedSetId ?? (sets.isNotEmpty ? sets.first.id : null);
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Controls', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 32),
                  
                  // Select List
                  const Text('Select List to Train'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: sets.any((s) => s.id == selectedSetId) ? selectedSetId : null,
                    items: sets.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (val) => context.read<PracticeCubit>().updateSettings(selectedSetId: val),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Select source column
                  const Text('What should be shown?'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: practiceState.sourceColumn,
                    items: [
                      const DropdownMenuItem(value: 'Symbols', child: Text('Symbols / Enum')),
                      ...vocabState.languages.map((l) => DropdownMenuItem(value: l, child: Text(l))),
                    ],
                    onChanged: (val) => context.read<PracticeCubit>().updateSettings(sourceColumn: val),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sequence Length
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sequence Length'),
                      Text(practiceState.sequenceLength.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    ],
                  ),
                  Slider(
                    value: practiceState.sequenceLength.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: practiceState.sequenceLength.toString(),
                    onChanged: (val) => context.read<PracticeCubit>().updateSettings(sequenceLength: val.round()),
                  ),
                  
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final set = vocabState.sets.firstWhere((s) => s.id == selectedSetId, orElse: () => vocabState.sets.first);
                        context.read<PracticeCubit>().scramble(set);
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

  Widget _buildMainArea(BuildContext context) {
    return BlocBuilder<PracticeCubit, PracticeState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.sequence.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: state.sequence.join(' ')));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('Copy'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.sequence.isEmpty
                  ? Center(child: Text('Press Scramble to generate a sequence', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: state.sequence.map((item) => _buildSequenceItem(context, item, state.sourceColumn)).toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSequenceItem(BuildContext context, String text, String source) {
    if (source == 'Symbols') {
      return Text(
        text,
        style: const TextStyle(fontSize: 48),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }
  }
}
