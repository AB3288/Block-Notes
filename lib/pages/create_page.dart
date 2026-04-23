import 'package:flutter/material.dart';
import '../models/note.dart';

class CreateNotePage extends StatefulWidget {
  final Note? note;
  const CreateNotePage({super.key, this.note});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _contenuController = TextEditingController();
  String selectedColor = "#FFE082";
  final List<String> colors = [
    "#FFE082",
    "#81D4FA",
    "#A5D6A7",
    "#FFAB91",
    "#CE93D8",
    "#90CAF9",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titreController.text = widget.note!.titre;
      _contenuController.text = widget.note!.contenu;
      selectedColor = widget.note!.couleur;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? "Créer Note" : "Modifier Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titreController,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: "Titre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contenuController,
              minLines: 4,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "Contenu",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: _hexToColor(color),
                    radius: selectedColor == color ? 22 : 18,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (_titreController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Titre obligatoire")),
                  );
                  return;
                }
                final note = Note(
                  id: widget.note?.id ?? DateTime.now().toString(),
                  titre: _titreController.text,
                  contenu: _contenuController.text,
                  couleur: selectedColor,
                  dateCreation:
                      widget.note?.dateCreation ?? DateTime.now(),
                  dateModification: DateTime.now(),
                );
                Navigator.pop(context, note);
              },
              child: const Text("Sauvegarder"),
            ),
          ],
        ),
      ),
    );
  }
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}