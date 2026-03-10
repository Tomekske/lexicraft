import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/vocab_cubit.dart';
import '../../data/models/vocab_models.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _langController = TextEditingController();
  final TextEditingController _setController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLanguageBar(context),
        const Divider(height: 1),
        Expanded(
          child: Row(
            children: [
              _buildSetSidebar(context),
              const VerticalDivider(width: 1),
              Expanded(child: _buildTableEditor(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageBar(BuildContext context) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              const Text('Languages:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              ...state.languages.map((lang) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text(lang),
                  onDeleted: () => context.read<VocabCubit>().removeLanguage(lang),
                  deleteIcon: const Icon(Icons.close, size: 14),
                ),
              )),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _langController,
                  decoration: const InputDecoration(
                    hintText: 'New Language...',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onSubmitted: (val) {
                    if (val.isNotEmpty) {
                      context.read<VocabCubit>().addLanguage(val);
                      _langController.clear();
                    }
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_langController.text.isNotEmpty) {
                    context.read<VocabCubit>().addLanguage(_langController.text);
                    _langController.clear();
                  }
                },
                icon: const Icon(Icons.add_circle, color: Colors.orangeAccent),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetSidebar(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<VocabCubit, VocabState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('List Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: state.sets.length,
                  itemBuilder: (context, index) {
                    final set = state.sets[index];
                    final isSelected = state.selectedSetId == set.id;
                    return ListTile(
                      title: Text(set.name, style: TextStyle(color: isSelected ? Colors.orangeAccent : null)),
                      selected: isSelected,
                      onTap: () => context.read<VocabCubit>().selectSet(set.id),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => context.read<VocabCubit>().deleteSet(set.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _setController,
                decoration: const InputDecoration(
                  hintText: 'New List Name...',
                  isDense: true,
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    context.read<VocabCubit>().addSet(val);
                    _setController.clear();
                  }
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_setController.text.isNotEmpty) {
                      context.read<VocabCubit>().addSet(_setController.text);
                      _setController.clear();
                    }
                  },
                  child: const Text('Add List'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableEditor(BuildContext context) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, state) {
        final selectedSet = state.selectedSet;
        if (selectedSet == null) {
          return const Center(child: Text('Select or create a list to edit'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'List Name'),
                      controller: TextEditingController(text: selectedSet.name)..selection = TextSelection.fromPosition(TextPosition(offset: selectedSet.name.length)),
                      onChanged: (val) => context.read<VocabCubit>().updateSetName(selectedSet.id, val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<VocabCubit>().addItemToSelectedSet(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Row'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Enum / ID')),
                      ...state.languages.map((lang) => DataColumn(label: Text(lang))),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: selectedSet.items.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(_buildEditableCell(context, selectedSet.id, item, 'enum')),
                          ...state.languages.map((lang) => DataCell(_buildEditableCell(context, selectedSet.id, item, lang))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            onPressed: () => context.read<VocabCubit>().deleteItem(selectedSet.id, item.id),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableCell(BuildContext context, String setId, VocabItem item, String field) {
    final text = field == 'enum' ? item.enumValue : (item.translations[field] ?? '');
    
    return IntrinsicWidth(
      child: TextField(
        controller: TextEditingController(text: text)..selection = TextSelection.fromPosition(TextPosition(offset: text.length)),
        onChanged: (val) {
          if (field == 'enum') {
            context.read<VocabCubit>().updateItem(setId, item.copyWith(enumValue: val));
          } else {
            final newTranslations = Map<String, String>.from(item.translations);
            newTranslations[field] = val;
            context.read<VocabCubit>().updateItem(setId, item.copyWith(translations: newTranslations));
          }
        },
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          fillColor: Colors.transparent,
        ),
      ),
    );
  }
}
