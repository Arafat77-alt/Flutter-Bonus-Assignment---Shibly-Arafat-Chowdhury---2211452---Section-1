import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/coffee_records_model.dart';
import '../state_management/coffee_state_management.dart';

class CoffeeRecordsScreen extends StatelessWidget {
  const CoffeeRecordsScreen({super.key});

  void _showAddEditDialog(BuildContext context, {CoffeeRecordsModel? record}) {
    final nameController = TextEditingController(text: record?.name ?? '');
    final priceController =
        TextEditingController(text: record != null ? record.price.toString() : '');
    String selectedSize = record?.size ?? 'Medium';
    String selectedSugar = record?.sugarLevel ?? 'Regular';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(record == null ? 'Add Coffee Order' : 'Edit Coffee Order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Coffee Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (\$)'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedSize,
                  items: ['Small', 'Medium', 'Large']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => selectedSize = val!,
                  decoration: const InputDecoration(labelText: 'Size'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedSugar,
                  items: ['No Sugar', 'Less', 'Regular', 'Extra']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => selectedSugar = val!,
                  decoration: const InputDecoration(labelText: 'Sugar Level'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 0.0;

                if (name.isNotEmpty && price > 0) {
                  final newRecord = CoffeeRecordsModel(
                    name: name,
                    price: price,
                    size: selectedSize,
                    sugarLevel: selectedSugar,
                    createdAt: record?.createdAt ?? DateTime.now(),
                  );

                  final provider = Provider.of<CoffeeStateManagement>(
                      context,
                      listen: false);

                  if (record == null) {
                    provider.addCoffeeRecord(newRecord);
                  } else {
                    provider.updateCoffeeRecord(record.id!, newRecord);
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(record == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coffeeState = Provider.of<CoffeeStateManagement>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Firestore Streams'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<CoffeeRecordsModel>>(
        stream: coffeeState.coffeeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(
              child: Text('No coffee records found. Click + to add one!'),
            );
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final item = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.coffee, color: Colors.white),
                  ),
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      '${item.size} • ${item.sugarLevel} Sugar • \$${item.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            _showAddEditDialog(context, record: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (item.id != null) {
                            coffeeState.deleteCoffeeRecord(item.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}