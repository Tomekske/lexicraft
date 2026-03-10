import '../models/vocab_models.dart';

abstract class VocabRepository {
  Future<List<String>> getLanguages();
  Future<void> addLanguage(String language);
  Future<void> removeLanguage(String language);
  Future<List<VocabSet>> getSets();
  Future<void> saveSet(VocabSet set);
  Future<void> deleteSet(String setId);
}

class MockVocabRepository implements VocabRepository {
  final List<String> _languages = ["Nederlands", "Polski", "English"];
  final List<VocabSet> _sets = [
    VocabSet(
      id: "set-1",
      name: "Seasons",
      items: [
        VocabItem(id: "item-1-1", enumValue: "❄️", translations: {"Nederlands": "Winter", "Polski": "Zima", "English": "Winter"}),
        VocabItem(id: "item-1-2", enumValue: "🌼", translations: {"Nederlands": "Lente", "Polski": "Wiosna", "English": "Spring"}),
        VocabItem(id: "item-1-3", enumValue: "☀️", translations: {"Nederlands": "Zomer", "Polski": "Lato", "English": "Summer"}),
        VocabItem(id: "item-1-4", enumValue: "🍂", translations: {"Nederlands": "Herfst", "Polski": "Jesień", "English": "Fall"}),
      ],
    ),
    VocabSet(
      id: "set-2",
      name: "Directions",
      items: [
        VocabItem(id: "item-2-1", enumValue: "⬆️", translations: {"Nederlands": "Noord", "Polski": "Północ", "English": "North"}),
        VocabItem(id: "item-2-2", enumValue: "➡️", translations: {"Nederlands": "Oost", "Polski": "Wschód", "English": "East"}),
        VocabItem(id: "item-2-3", enumValue: "⬇️", translations: {"Nederlands": "Zuid", "Polski": "Południe", "English": "South"}),
        VocabItem(id: "item-2-4", enumValue: "⬅️", translations: {"Nederlands": "West", "Polski": "Zachód", "English": "West"}),
      ],
    ),
    VocabSet(
      id: "set-3",
      name: "Days of the Week",
      items: [
        VocabItem(id: "item-3-1", enumValue: "1", translations: {"Nederlands": "Maandag", "Polski": "Poniedziałek", "English": "Monday"}),
        VocabItem(id: "item-3-2", enumValue: "2", translations: {"Nederlands": "Dinsdag", "Polski": "Wtorek", "English": "Tuesday"}),
        VocabItem(id: "item-3-3", enumValue: "3", translations: {"Nederlands": "Woensdag", "Polski": "Środa", "English": "Wednesday"}),
        VocabItem(id: "item-3-4", enumValue: "4", translations: {"Nederlands": "Donderdag", "Polski": "Czwartek", "English": "Thursday"}),
        VocabItem(id: "item-3-5", enumValue: "5", translations: {"Nederlands": "Vrijdag", "Polski": "Piątek", "English": "Friday"}),
        VocabItem(id: "item-3-6", enumValue: "6", translations: {"Nederlands": "Zaterdag", "Polski": "Sobota", "English": "Saturday"}),
        VocabItem(id: "item-3-7", enumValue: "7", translations: {"Nederlands": "Zondag", "Polski": "Niedziela", "English": "Sunday"}),
      ],
    ),
  ];

  @override
  Future<List<String>> getLanguages() async {
    return List.from(_languages);
  }

  @override
  Future<void> addLanguage(String language) async {
    if (!_languages.contains(language)) {
      _languages.add(language);
    }
  }

  @override
  Future<void> removeLanguage(String language) async {
    _languages.remove(language);
    // In a real app, we might also remove translations for this language from all items
  }

  @override
  Future<List<VocabSet>> getSets() async {
    return List.from(_sets);
  }

  @override
  Future<void> saveSet(VocabSet set) async {
    final index = _sets.indexWhere((s) => s.id == set.id);
    if (index != -1) {
      _sets[index] = set;
    } else {
      _sets.add(set);
    }
  }

  @override
  Future<void> deleteSet(String setId) async {
    _sets.removeWhere((s) => s.id == setId);
  }
}
