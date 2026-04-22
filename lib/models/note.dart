class Note {
  final String id;
  final String titre;
  final String contenu;
  final String couleur;
  final DateTime dateCreation;
  final DateTime? dateModification;

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.couleur,
    required this.dateCreation,
    this.dateModification,
  }) {
    if (titre.length > 60) {
      throw Exception("Le titre ne doit pas dépasser 60 caractères");
    }

    if (!couleur.startsWith('#') || couleur.length != 7) {
      throw Exception("Format couleur invalide (ex: #FFE082)");
    }
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      titre: json['titre'],
      contenu: json['contenu'],
      couleur: json['couleur'],
      dateCreation: DateTime.parse(json['dateCreation']),
      dateModification: json['dateModification'] != null
          ? DateTime.parse(json['dateModification'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'contenu': contenu,
      'couleur': couleur,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  Note copyWith({
    String? titre,
    String? contenu,
    String? couleur,
    DateTime? dateModification,
  }) {
    return Note(
      id: id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      couleur: couleur ?? this.couleur,
      dateCreation: dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}