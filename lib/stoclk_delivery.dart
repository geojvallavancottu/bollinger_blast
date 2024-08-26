import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockDeliverySearchPage extends StatefulWidget {
  @override
  _StockDeliverySearchPageState createState() =>
      _StockDeliverySearchPageState();
}

class _StockDeliverySearchPageState extends State<StockDeliverySearchPage> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  List<Map<String, dynamic>> _stockDeliveries = [];

  Future<void> _search() async {
    final startDate = _startDateController.text;
    final endDate = _endDateController.text;
    final results = await fetchStockDelivery(startDate, endDate);
    setState(() {
      _stockDeliveries = results;
    });
  }

  Future<List<Map<String, dynamic>>> fetchStockDelivery(
      String startDate, String endDate) async {
    final response = await Supabase.instance.client
        .from('stock_delivery')
        .select()
        .gte('date', startDate)
        .lte('date', endDate)
        .order('delivery_percentage', ascending: false)
        ;

    if (response.isEmpty) {
      return [];
    } 
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Delivery Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date (yyyy-mm-dd)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date (yyyy-mm-dd)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Search'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _stockDeliveries.length,
                itemBuilder: (context, index) {
                  final stock = _stockDeliveries[index];
                  return ListTile(
                    title: Text(stock['stock']),
                    subtitle:
                        Text('Delivery: ${stock['delivery_percentage']}%'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
