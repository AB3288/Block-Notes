import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import '../models/note.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {        
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';                       
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NoteService>();
    final displayedNotes = service.search(_query);  // filtrées + triées

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: const Text(
          "Notes",
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // ── Fonctionnalité 3 : compteur avec Consumer ciblé ──
        leading: Consumer<NoteService>(
          builder: (_, svc, __) => Center(
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${svc.count}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        // ── Fonctionnalité 2 : menu de tri ──
        actions: [
          Consumer<NoteService>(
            builder: (_, svc, __) => PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort, color: Colors.white),
              tooltip: "Trier",
              onSelected: (option) => svc.setSortOption(option),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: SortOption.dateDesc,
                  child: Text("Date (récent d'abord)"),
                ),
                PopupMenuItem(
                  value: SortOption.dateAsc,
                  child: Text("Date (ancien d'abord)"),
                ),
                PopupMenuItem(
                  value: SortOption.titleAsc,
                  child: Text("Titre (A → Z)"),
                ),
                PopupMenuItem(
                  value: SortOption.titleDesc,
                  child: Text("Titre (Z → A)"),
                ),
              ],
            ),
          ),
        ],
        // ── Fonctionnalité 1 : barre de recherche ──
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Rechercher une note...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white12,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Note>(
            context,
            MaterialPageRoute(builder: (_) => const CreateNotePage()),
          );
          if (result != null && context.mounted) {
            context.read<NoteService>().addNote(result);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: displayedNotes.isEmpty
          ? Center(
              child: Text(
                _query.isEmpty ? "Aucune note" : "Aucun résultat pour \"$_query\"",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: displayedNotes.length,
              itemBuilder: (context, index) {
                final note = displayedNotes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailNotePage(note: note, index: index),
                        ),
                      );
                      if (result != null && context.mounted) {
                        if (result["action"] == "modified") {
                          context.read<NoteService>().updateNote(result["note"] as Note);
                        }
                        if (result["action"] == "deleted") {
                          context.read<NoteService>().deleteNote(result["id"] as String);
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 90,
                            decoration: BoxDecoration(
                              color: _hexToColor(note.couleur),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.titre,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note.contenu.length > 40
                                        ? "${note.contenu.substring(0, 40)}..."
                                        : note.contenu,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${note.dateCreation.day}/${note.dateCreation.month}/${note.dateCreation.year}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}