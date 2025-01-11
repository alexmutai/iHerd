import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(const DocumentUploadApp());
}

class DocumentUploadApp extends StatelessWidget {
  const DocumentUploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Upload',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DocumentUploadScreen(),
    );
  }
}

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final Map<String, List<Document>> cowDocuments = {}; // Store documents for each cow
  final List<String> cowNames = [];

  Future<void> addCow() async {
    String? cowName = await _promptForName();
    if (cowName != null && cowName.isNotEmpty) {
      setState(() {
        if (!cowDocuments.containsKey(cowName)) {
          cowDocuments[cowName] = [];
          cowNames.add(cowName);
        }
      });
    }
  }

  Future<String?> _promptForName() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String name = '';
        return AlertDialog(
          title: const Text('Enter Cow Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: const InputDecoration(hintText: "Cow Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name.isEmpty ? null : name);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadDocument(String cowName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        String? description = await _promptForDescription();
        if (description != null && description.isNotEmpty) {
          String fullDescription = '$description - Document added on ${DateFormat('d MMMM yyyy').format(DateTime.now())}';
          setState(() {
            cowDocuments[cowName]?.add(Document(file: file, description: fullDescription));
          });
        }
      }
    } on PlatformException catch (e) {
      print('Error while picking the file: $e');
    }
  }

  Future<String?> _promptForDescription() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String description = '';
        return AlertDialog(
          title: const Text('Enter Document Description'),
          content: TextField(
            onChanged: (value) {
              description = value;
            },
            decoration: const InputDecoration(hintText: "Document Description"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(description.isEmpty ? null : description);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void editCowName(String oldName, String newName) {
    setState(() {
      List<Document>? documents = cowDocuments.remove(oldName);
      if (documents != null) {
        cowDocuments[newName] = documents;
      }
      int index = cowNames.indexOf(oldName);
      if (index != -1) {
        cowNames[index] = newName;
      }
    });
  }

  void _viewImage(File image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImage(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload'),
        backgroundColor: Colors.deepPurple[800],
      ),
      backgroundColor: Colors.purple[50],
      body: cowNames.isEmpty
          ? Center(
              child: Text(
                'No cows added yet.',
                style: TextStyle(fontSize: 18, color: Colors.purple[700]),
              ),
            )
          : ListView.builder(
              itemCount: cowNames.length,
              itemBuilder: (context, index) {
                String cowName = cowNames[index];
                return Dismissible(
                  key: Key(cowName),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text('Are you sure you want to delete "$cowName"? This action cannot be undone.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Delete'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                      return confirm;
                    }
                    return false;
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(
                        cowName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          shrinkWrap: true,
                          itemCount: cowDocuments[cowName]?.length ?? 0,
                          itemBuilder: (context, docIndex) {
                            Document doc = cowDocuments[cowName]![docIndex];
                            return ListTile(
                              contentPadding: const EdgeInsets.all(8.0),
                              leading: IconButton(
                                icon: Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  _viewImage(doc.file);
                                },
                              ),
                              title: Text(doc.description),
                            );
                          },
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                uploadDocument(cowName);
                              },
                              child: const Text('Add More Documents'),
                            ),
                            TextButton(
                              onPressed: () async {
                                String? newName = await _promptForName();
                                if (newName != null) {
                                  editCowName(cowName, newName);
                                }
                              },
                              child: const Text('Edit Name'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCow,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Document {
  final File file;
  final String description;

  Document({required this.file, required this.description});
}

class FullScreenImage extends StatelessWidget {
  final File image;

  const FullScreenImage({required this.image, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[800],
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Image.file(
          image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
