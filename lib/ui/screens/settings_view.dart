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
  bool _showingEditorOnMobile = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 700;

        return Column(
          children: [
            _buildLanguageBar(context, isMobile),
            const Divider(height: 1),
            Expanded(
              child: isMobile
                  ? _buildMobileContent(context)
                  : Row(
                      children: [
                        _buildSetSidebar(context),
                        const VerticalDivider(width: 1),
                        Expanded(child: _buildTableEditor(context)),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, state) {
        if (_showingEditorOnMobile && state.selectedSetId != null) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () => setState(() => _showingEditorOnMobile = false),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Lists'),
                ),
              ),
              Expanded(child: _buildTableEditor(context, isMobile: true)),
            ],
          );
        }
        return _buildSetSidebar(context, onSetSelected: () {
          setState(() => _showingEditorOnMobile = true);
        });
      },
    );
  }

  Widget _buildLanguageBar(BuildContext context, bool isMobile) {
    return BlocBuilder<VocabCubit, VocabState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Languages:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...state.languages.map((lang) => Chip(
                        label: Text(lang),
                        onDeleted: () =>
                            context.read<VocabCubit>().removeLanguage(lang),
                        deleteIcon: const Icon(Icons.close, size: 14),
                      )),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 150,
                        child: TextField(
                          controller: _langController,
                          decoration: const InputDecoration(
                            hintText: 'New Language...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
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
                            context
                                .read<VocabCubit>()
                                .addLanguage(_langController.text);
                            _langController.clear();
                          }
                        },
                        icon: const Icon(Icons.add_circle,
                            color: Colors.orangeAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSetSidebar(BuildContext context, {VoidCallback? onSetSelected}) {
    return Container(
      width: onSetSelected == null ? 250 : double.infinity,
      padding: const EdgeInsets.all(16),
      child: BlocBuilder<VocabCubit, VocabState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('List Manager',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: state.sets.length,
                  itemBuilder: (context, index) {
                    final set = state.sets[index];
                    final isSelected = state.selectedSetId == set.id;
                    return ListTile(
                      title: Text(set.name,
                          style: TextStyle(
                              color: isSelected ? Colors.orangeAccent : null)),
                      selected: isSelected,
                      onTap: () {
                        context.read<VocabCubit>().selectSet(set.id);
                        onSetSelected?.call();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () =>
                            context.read<VocabCubit>().deleteSet(set.id),
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

  Widget _buildTableEditor(BuildContext context, {bool isMobile = false}) {
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
              child: isMobile
                  ? Column(
                      children: [
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'List Name'),
                          controller: TextEditingController(text: selectedSet.name)
                            ..selection = TextSelection.fromPosition(
                                TextPosition(offset: selectedSet.name.length)),
                          onChanged: (val) => context
                              .read<VocabCubit>()
                              .updateSetName(selectedSet.id, val),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                context.read<VocabCubit>().addItemToSelectedSet(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Row'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orangeAccent.withValues(alpha: 0.1),
                              foregroundColor: Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'List Name'),
                            controller: TextEditingController(
                                text: selectedSet.name)
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: selectedSet.name.length)),
                            onChanged: (val) => context
                                .read<VocabCubit>()
                                .updateSetName(selectedSet.id, val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () =>
                              context.read<VocabCubit>().addItemToSelectedSet(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Row'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.orangeAccent.withValues(alpha: 0.1),
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
                      ...state.languages
                          .map((lang) => DataColumn(label: Text(lang))),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: selectedSet.items.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(_buildEditableCell(
                              context, selectedSet.id, item, 'enum')),
                          ...state.languages.map((lang) => DataCell(
                              _buildEditableCell(
                                  context, selectedSet.id, item, lang))),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent, size: 20),
                            onPressed: () => context
                                .read<VocabCubit>()
                                .deleteItem(selectedSet.id, item.id),
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
