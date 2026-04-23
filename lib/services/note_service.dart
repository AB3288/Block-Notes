import 'package:flutter/foundation.dart';
import '../models/note.dart';

enum SortOption {
  dateDesc,  // récent d'abord (défaut)
  dateAsc,   // ancien d'abord
  titleAsc,  // A → Z
  titleDesc, // Z → A
}

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  SortOption _sortOption = SortOption.dateDesc;

  SortOption get sortOption => _sortOption;

  List<Note> get notes {
    final sorted = [..._notes];
    switch (_sortOption) {
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.dateCreation.compareTo(b.dateCreation));
      case SortOption.titleAsc:
        sorted.sort((a, b) => a.titre.compareTo(b.titre));
      case SortOption.titleDesc:
        sorted.sort((a, b) => b.titre.compareTo(a.titre));
    }
    return List.unmodifiable(sorted);
  }

  int get count => _notes.length;

  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }

  void updateNote(Note note) {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Note> search(String query) {
    if (query.trim().isEmpty) return notes;
    final q = query.toLowerCase();
    return notes
        .where((n) =>
            n.titre.toLowerCase().contains(q) ||
            n.contenu.toLowerCase().contains(q))
        .toList();
  }
}