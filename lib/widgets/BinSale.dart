import 'package:flutter/material.dart';

class SellingBinsWidget extends StatefulWidget {
  @override
  _SellingBinsWidgetState createState() => _SellingBinsWidgetState();
}

class _SellingBinsWidgetState extends State<SellingBinsWidget> {
  List<Map<String, dynamic>> _bins = [];

  @override
  Widget build(BuildContext context) {
    // Ensure _bins is initialized and not null
    if (_bins == null) {
      _bins = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selling Bins', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ..._bins.map((bin) => binCard(bin)).toList(),
        addButton('Add Another Selling Bin', () {
          setState(() {
            _bins.add({'image': null, 'price': ''});
          });
        }),
      ],
    );
  }

  Widget binCard(Map<String, dynamic> bin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Image.asset(
              bin['image'] ?? "assets/images/choose.png",
              height: 100,
              width: 100,
            ),
            DropdownButtonFormField<String>(
              value: bin['image'] as String?, // Ensure type safety
              hint: Text('Select Bin Image'),
              items: [
                DropdownMenuItem(child: Text('Borla Extra - 240L'), value: 'assets/images/240L.png'),
                DropdownMenuItem(child: Text('Borla General-140L'), value: 'assets/images/140.png'),
                DropdownMenuItem(child: Text('Borla Medium -100L'), value: 'assets/images/100l.png'),
                DropdownMenuItem(child: Text('Borla Bag'), value: 'assets/images/plasticbag.png'),
              ],
              onChanged: (value) {
                setState(() {
                  bin['image'] = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a bin image';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price for selected bin'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                bin['price'] = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _bins.remove(bin);
                });
              },
              child: Text('Remove Bin'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget addButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Icon(Icons.add),
      ),
    );
  }
}
