import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  final List<String> recordedValues;
  final String clientInfo;

  const ListPage(this.recordedValues, this.clientInfo);

  @override
  Widget build(BuildContext context) {
    recordedValues.sort((a, b) {
      String dateA = a.split('Date: ')[1].split(', ')[0];
      String dateB = b.split('Date: ')[1].split(', ')[0];
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Recorded Values for $clientInfo"),
        titleSpacing: 75.0,
        backgroundColor: Color.fromARGB(255, 49, 187, 180),
      ),
      body: ListView.builder(
        itemCount: recordedValues.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recordedValues[index]),
          );
        },
      ),
    );
  }
}
