import 'package:flutter/material.dart';

class MilkSale {
  final String clientName;
  final double quantity;
  final double price;
  final DateTime date;

  MilkSale({required this.clientName, required this.quantity, required this.price, required this.date});
}

class MilkSalesPage extends StatefulWidget {
  final double milkAvailable;

  const MilkSalesPage({Key? key, required this.milkAvailable}) : super(key: key);

  @override
  _MilkSalesPageState createState() => _MilkSalesPageState();
}

class _MilkSalesPageState extends State<MilkSalesPage> {
  List<MilkSale> milkSales = [];
  double milkAvailable = 0.0;

  @override
  void initState() {
    super.initState();
    milkAvailable = widget.milkAvailable;
  }

  void _addSale(String clientName, double quantity, double price) {
    if (quantity <= milkAvailable) {
      setState(() {
        milkSales.add(MilkSale(clientName: clientName, quantity: quantity, price: price, date: DateTime.now()));
        milkAvailable -= quantity;
      });
    } else {
      _showErrorDialog('Not enough milk available.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.deepPurple[700],
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSaleDialog() {
    final TextEditingController clientNameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[700],
          title: Text('New Sale', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: clientNameController,
                  decoration: InputDecoration(
                    labelText: 'Client Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity (Liters)',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Price per Liter',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple[800],
              ),
              onPressed: () {
                final String clientName = clientNameController.text;
                final double quantity = double.tryParse(quantityController.text) ?? 0.0;
                final double price = double.tryParse(priceController.text) ?? 0.0;

                if (clientName.isNotEmpty && quantity > 0 && price > 0) {
                  _addSale(clientName, quantity, price);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Please enter valid data.');
                }
              },
              child: Text('Add Sale'),
            ),
          ],
        );
      },
    );
  }

  void _editMilkAvailable() {
    final TextEditingController milkAvailableController = TextEditingController(text: milkAvailable.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[700],
          title: Text('Edit Milk Available', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: milkAvailableController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Milk Available (Liters)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple[800],
              ),
              onPressed: () {
                final double updatedMilkAvailable = double.tryParse(milkAvailableController.text) ?? milkAvailable;
                setState(() {
                  milkAvailable = updatedMilkAvailable;
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _generateReceipt() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[700],
          title: Text('Receipt', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...milkSales.map((sale) => Text(
                '${sale.clientName}: ${sale.quantity} Liters @ ${sale.price}/L',
                style: TextStyle(color: Colors.white70),
              )),
              SizedBox(height: 10),
              Text(
                'Total: ${milkSales.fold(0.0, (sum, sale) => sum + (sale.quantity * sale.price))} KES',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Milk Sales'),
        backgroundColor: Colors.deepPurple[700],
        actions: [
          IconButton(
            icon: Icon(Icons.receipt),
            onPressed: _generateReceipt,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onLongPress: _editMilkAvailable,
              child: Text(
                'Milk Available: $milkAvailable Liters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple[700],
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              onPressed: _showSaleDialog,
              child: Text('Add Sale', style: TextStyle(fontSize: 18.0)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: milkSales.length,
                itemBuilder: (context, index) {
                  final sale = milkSales[index];
                  return Card(
                    color: Colors.deepPurple[600],
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        '${sale.clientName} - ${sale.quantity} Liters',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${sale.date.toLocal()}',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        '${sale.price} KES/L',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.deepPurple[800],
    );
  }
}
