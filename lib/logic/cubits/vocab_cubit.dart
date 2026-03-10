import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/vocab_models.dart';
import '../../data/repositories/vocab_repository.dart';

class VocabState extends Equatable {
  final List<String> languages;
  final List<VocabSet> sets;
  final String? selectedSetId;
  final bool isLoading;

  const VocabState({
    this.languages = const [],
    this.sets = const [],
    this.selectedSetId,
    this.isLoading = false,
  });

  VocabSet? get selectedSet {
    if (selectedSetId == null) return null;
    return sets.firstWhere((s) => s.id == selectedSetId, orElse: () => sets.first);
  }

  VocabState copyWith({
    List<String>? languages,
    List<VocabSet>? sets,
    String? selectedSetId,
    bool? isLoading,
  }) {
    return VocabState(
      languages: languages ?? this.languages,
      sets: sets ?? this.sets,
      selectedSetId: selectedSetId ?? this.selectedSetId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [languages, sets, selectedSetId, isLoading];
}

class VocabCubit extends Cubit<VocabState> {
  final VocabRepository _repository;
  final _uuid = const Uuid();

  VocabCubit(this._repository) : super(const VocabState()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    final languages = await _repository.getLanguages();
    final sets = await _repository.getSets();
    emit(state.copyWith(
      languages: languages,
      sets: sets,
      isLoading: false,
      selectedSetId: sets.isNotEmpty ? sets.first.id : null,
    ));
  }

  void selectSet(String? setId) {
    emit(state.copyWith(selectedSetId: setId));
  }

  Future<void> addLanguage(String language) async {
    await _repository.addLanguage(language);
    await loadData();
  }

  Future<void> removeLanguage(String language) async {
    await _repository.removeLanguage(language);
    await loadData();
  }

  Future<void> addSet(String name) async {
    final newSet = VocabSet(
      id: _uuid.v4(),
      name: name,
      items: const [],
    );
    await _repository.saveSet(newSet);
    await loadData();
    selectSet(newSet.id);
  }

  Future<void> deleteSet(String setId) async {
    await _repository.deleteSet(setId);
    await loadData();
    if (state.selectedSetId == setId) {
      emit(state.copyWith(selectedSetId: state.sets.isNotEmpty ? state.sets.first.id : null));
    }
  }

  Future<void> addItemToSelectedSet() async {
    final selectedSet = state.selectedSet;
    if (selectedSet == null) return;

    final newItem = VocabItem(
      id: _uuid.v4(),
      enumValue: '',
      translations: {for (var lang in state.languages) lang: ''},
    );

    final updatedSet = selectedSet.copyWith(
      items: [...selectedSet.items, newItem],
    );
    await _repository.saveSet(updatedSet);
    await loadData();
  }

  Future<void> updateItem(String setId, VocabItem item) async {
    final setIndex = state.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;

    final set = state.sets[setIndex];
    final itemIndex = set.items.indexWhere((i) => i.id == item.id);
    if (itemIndex == -1) return;

    final updatedItems = List<VocabItem>.from(set.items);
    updatedItems[itemIndex] = item;

    final updatedSet = set.copyWith(items: updatedItems);
    await _repository.saveSet(updatedSet);
    await loadData();
  }

  Future<void> deleteItem(String setId, String itemId) async {
    final setIndex = state.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;

    final set = state.sets[setIndex];
    final updatedItems = set.items.where((i) => i.id != itemId).toList();

    final updatedSet = set.copyWith(items: updatedItems);
    await _repository.saveSet(updatedSet);
    await loadData();
  }
  
  Future<void> updateSetName(String setId, String newName) async {
    final setIndex = state.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;
    
    final updatedSet = state.sets[setIndex].copyWith(name: newName);
    await _repository.saveSet(updatedSet);
    await loadData();
  }
}
