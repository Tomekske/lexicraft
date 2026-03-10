import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/vocab_models.dart';

class PracticeState extends Equatable {
  final String? selectedSetId;
  final String sourceColumn; // 'Symbols' or a language name
  final int sequenceLength;
  final List<String> sequence;

  const PracticeState({
    this.selectedSetId,
    this.sourceColumn = 'Symbols',
    this.sequenceLength = 20,
    this.sequence = const [],
  });

  PracticeState copyWith({
    String? selectedSetId,
    String? sourceColumn,
    int? sequenceLength,
    List<String>? sequence,
  }) {
    return PracticeState(
      selectedSetId: selectedSetId ?? this.selectedSetId,
      sourceColumn: sourceColumn ?? this.sourceColumn,
      sequenceLength: sequenceLength ?? this.sequenceLength,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  List<Object?> get props => [selectedSetId, sourceColumn, sequenceLength, sequence];
}

class PracticeCubit extends Cubit<PracticeState> {
  PracticeCubit() : super(const PracticeState());

  void updateSettings({
    String? selectedSetId,
    String? sourceColumn,
    int? sequenceLength,
  }) {
    emit(state.copyWith(
      selectedSetId: selectedSetId,
      sourceColumn: sourceColumn,
      sequenceLength: sequenceLength,
    ));
  }

  void scramble(VocabSet? selectedSet) {
    if (selectedSet == null || selectedSet.items.isEmpty) {
      emit(state.copyWith(sequence: []));
      return;
    }

    final random = Random();
    final List<String> availableStrings = selectedSet.items.map((item) {
      if (state.sourceColumn == 'Symbols') {
        return item.enumValue;
      } else {
        return item.translations[state.sourceColumn] ?? '';
      }
    }).where((s) => s.isNotEmpty).toList();

    if (availableStrings.isEmpty) {
      emit(state.copyWith(sequence: []));
      return;
    }

    final List<String> result = [];
    String? lastLast;
    String? last;

    for (int i = 0; i < state.sequenceLength; i++) {
      String next;
      // Scramble logic: prevent exact same string 3 times in a row
      if (availableStrings.length == 1) {
        next = availableStrings.first;
      } else {
        // Try to pick a string that isn't the same as the last two
        List<String> pool = availableStrings;
        if (last != null && last == lastLast) {
          pool = availableStrings.where((s) => s != last).toList();
        }
        
        if (pool.isEmpty) pool = availableStrings; // Fallback
        next = pool[random.nextInt(pool.length)];
      }

      result.add(next);
      lastLast = last;
      last = next;
    }

    emit(state.copyWith(sequence: result));
  }
}
