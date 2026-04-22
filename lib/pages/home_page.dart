import 'create_page.dart';
import 'detail_page.dart';
import 'package:flutter/material.dart';
import '../models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Note> _notes = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          "Notes",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateNotePage(),
            ),
          );
          if (result != null && result is Note) {
            setState(() {
              _notes.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _notes.isEmpty
          ? const Center(
              child: Text(
                "Aucune note",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailNotePage(note: note, index: index),
                        ),
                      );
                      if (result != null) {
                        if (result["action"] == "modified") {
                          setState(() {
                            _notes[index] = result["note"];
                          });
                        }
                        if (result["action"] == "deleted") {
                          setState(() {
                            _notes.removeAt(result["index"]);
                          });
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
                            color: _hexToColor(note.couleur),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.titre,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    note.contenu.length > 30
                                        ? "${note.contenu.substring(0, 30)}..."
                                        : note.contenu,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "${note.dateCreation.day}/${note.dateCreation.month}/${note.dateCreation.year}",
                                    style: const TextStyle(
                                      fontSize: 12,
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