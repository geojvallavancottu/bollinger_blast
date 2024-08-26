import 'package:bolingerblast/stoclk_delivery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  Supabase.initialize(
    url: 'https://uazqhghjnbrvulrduaca.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVhenFoZ2hqbmJydnVscmR1YWNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQwNTczNjgsImV4cCI6MjAyOTYzMzM2OH0.Ntz1KxXeKciFQNva0iZLmv_TyKhhvk7iHtnX00uNS9I',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Satoshi',
        primarySwatch: Colors.green,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime selectedDate = DateTime.now();

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchRsiCrossoverData(
      DateTime date) async {
    final response = await Supabase.instance.client
        .from('rsi_crossover')
        .select('*')
        .eq('date', date.toIso8601String().split('T')[0])
        .order('cross_price_diff', ascending: true);

    if (response.isEmpty) {
      print('Error fetching RSI Crossover data');
      return [];
    }

    return response;
  }

  Future<List<Map<String, dynamic>>> fetchStockDeliveryData(
      String stock, DateTime date) async {
    final response = await Supabase.instance.client
        .from('stock_delivery')
        .select('*')
        .eq('stock', stock)
        // .eq('date', date.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    if (response.isEmpty) {
      print('Error fetching Stock Delivery data');
      return [];
    }

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSI Crossover List'),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockDeliverySearchPage()),
              );
            },
            child: const Icon(Icons.list_alt),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("${selectedDate.toLocal()}".split(' ')[0]),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchRsiCrossoverData(selectedDate),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final List<Map<String, dynamic>> data = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return ExpansionTile(
                      trailing: InkWell(
                        onTap: () async {
                          final Uri url = Uri.parse(
                              'https://in.tradingview.com/chart/?symbol=NSE%3A${item['stock']}');
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.inAppWebView,
                            webOnlyWindowName: kIsWeb ? '_blank' : '_self',
                          )) {
                            throw Exception('Could not launch $url');
                          }
                        },
                        child: const Icon(Icons.arrow_right_alt_rounded),
                      ),
                      title: Text(
                        item['stock'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text('Cross Price Diff: ${item['cross_price_diff']}'),
                      children: [
                        FutureBuilder(
                          future: fetchStockDeliveryData(
                              item['stock'], selectedDate),
                          builder: (context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final List<Map<String, dynamic>> deliveryData =
                                snapshot.data ?? [];

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              itemCount: deliveryData.length,
                              itemBuilder: (context, index) {
                                final deliveryItem = deliveryData[index];
                                return ListTile(
                                  title: Text(
                                      'Delivery: ${deliveryItem['delivery_percentage']}%'),
                                  subtitle:
                                      Text('Date: ${deliveryItem['date']}'),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
