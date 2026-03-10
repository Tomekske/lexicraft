import 'package:equatable/equatable.dart';

class VocabItem extends Equatable {
  final String id;
  final String enumValue; // The emoji or symbol
  final Map<String, String> translations;

  const VocabItem({
    required this.id,
    required this.enumValue,
    required this.translations,
  });

  VocabItem copyWith({
    String? id,
    String? enumValue,
    Map<String, String>? translations,
  }) {
    return VocabItem(
      id: id ?? this.id,
      enumValue: enumValue ?? this.enumValue,
      translations: translations ?? Map<String, String>.from(this.translations),
    );
  }

  @override
  List<Object?> get props => [id, enumValue, translations];

  Map<String, dynamic> toJson() => {
    'id': id,
    'enum': enumValue,
    'translations': translations,
  };

  factory VocabItem.fromJson(Map<String, dynamic> json) => VocabItem(
    id: json['id'],
    enumValue: json['enum'],
    translations: Map<String, String>.from(json['translations']),
  );
}

class VocabSet extends Equatable {
  final String id;
  final String name;
  final List<VocabItem> items;

  const VocabSet({
    required this.id,
    required this.name,
    required this.items,
  });

  VocabSet copyWith({
    String? id,
    String? name,
    List<VocabItem>? items,
  }) {
    return VocabSet(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? List<VocabItem>.from(this.items),
    );
  }

  @override
  List<Object?> get props => [id, name, items];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((i) => i.toJson()).toList(),
  };

  factory VocabSet.fromJson(Map<String, dynamic> json) => VocabSet(
    id: json['id'],
    name: json['name'],
    items: (json['items'] as List).map((i) => VocabItem.fromJson(i)).toList(),
  );
}
