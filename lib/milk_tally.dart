import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MilkSaleApp());
}

class MilkSaleApp extends StatelessWidget {
  const MilkSaleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milk Sales',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.deepPurple[100],
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.deepPurple[900]),
          bodyText2: TextStyle(color: Colors.deepPurple[900]),
        ),
      ),
      home: const CircularImagePage(),
    );
  }
}

class CircularImagePage extends StatefulWidget {
  const CircularImagePage({Key? key}) : super(key: key);

  @override
  _CircularImagePageState createState() => _CircularImagePageState();
}

class _CircularImagePageState extends State<CircularImagePage> {
  List<Client> clients = [
    Client(name: 'LELMET', imagePath: 'assets/client1.png'),
    Client(name: 'KIPKENYO', imagePath: 'assets/client2.png'),
    Client(name: 'KITALE', imagePath: 'assets/client3.png'),
  ];

  final Map<String, int> clientQuantities = {};

  @override
  Widget build(BuildContext context) {
    int totalMilk = clientQuantities.values.fold(0, (sum, qty) => sum + qty);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MAZIWA (Total: $totalMilk L)',
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[700],
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.bar_chart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsPage(clientQuantities: clientQuantities),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientRecordsPage(clientQuantities: clientQuantities),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            ...clients.map((client) {
              return Container(
                width: 150,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[200],
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    _showInputPopup(context, client.name);
                  },
                  onLongPress: () {
                    _editClient(clients.indexOf(client));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[100],
                              shape: BoxShape.circle,
                            ),
                          ),
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: _getImage(client.imagePath),
                            child: _getImage(client.imagePath) == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 19, 19, 20),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Container(
              width: 150,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple[300],
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _addNewClient,
                child: Center(
                  child: const Text(
                    '+ Add Cattle',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object>? _getImage(String imagePath) {
    try {
      if (imagePath.startsWith('assets/')) {
        return AssetImage(imagePath);
      } else if (File(imagePath).existsSync()) {
        return FileImage(File(imagePath));
      }
    } catch (e) {
      print('Image not found: $e');
    }
    return null;
  }

  Future<void> _showInputPopup(BuildContext context, String clientName) async {
    final TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Enter quantity for $clientName',
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            height: 150,
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity (Liters)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                int quantity = int.tryParse(quantityController.text) ?? 0;
                setState(() {
                  clientQuantities[clientName] = quantity;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClientDialog({
    required BuildContext context,
    String? initialName,
    String? initialImagePath,
    required Function(String name, String imagePath) onSubmit,
  }) async {
    final TextEditingController nameController = TextEditingController();
    final ImagePicker _picker = ImagePicker();
    String newName = initialName ?? '';
    String newImagePath = initialImagePath ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            initialName == null ? 'Add New Client' : 'Edit Client',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController..text = newName,
                  decoration: const InputDecoration(
                    labelText: 'Client Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    newName = value;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        newImagePath = pickedFile.path;
                      });
                    }
                  },
                  child: const Text('Change Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit(newName, newImagePath);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addNewClient() {
    _showClientDialog(
      context: context,
      onSubmit: (name, imagePath) {
        setState(() {
          clients.add(Client(name: name, imagePath: imagePath));
        });
      },
    );
  }

  void _editClient(int index) {
    _showClientDialog(
      context: context,
      initialName: clients[index].name,
      initialImagePath: clients[index].imagePath,
      onSubmit: (name, imagePath) {
        setState(() {
          clients[index].name = name;
          clients[index].imagePath = imagePath;
        });
      },
    );
  }
}

class ClientRecordsPage extends StatelessWidget {
  final Map<String, int> clientQuantities;

  const ClientRecordsPage({Key? key, required this.clientQuantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Records'),
        backgroundColor: Colors.deepPurple[700],
      ),
      body: ListView(
        children: clientQuantities.entries.map((entry) {
          return ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${entry.value} Liters',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StatisticsPage extends StatelessWidget {
  final Map<String, int> clientQuantities;

  const StatisticsPage({Key? key, required this.clientQuantities}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Milk Production Statistics',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple[700],
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pie Chart Key:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...clientQuantities.keys.map((key) {
                return Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: _getColorForKey(key),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      key,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: clientQuantities.entries.map((entry) {
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '${entry.value} L',
                        color: _getColorForKey(entry.key),
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    centerSpaceRadius: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForKey(String key) {
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
    ];
    int index = clientQuantities.keys.toList().indexOf(key) % colors.length;
    return colors[index];
  }
}

class Client {
  String name;
  String imagePath;

  Client({required this.name, required this.imagePath});
}
