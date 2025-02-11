import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase/supabase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Entry {
  final String stock;
  final int crossover;
  final DateTime date;

  Entry({
    required this.stock,
    required this.crossover,
    required this.date,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      stock: json['stock'] as String,
      crossover: json['crossover'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class BollingerCrossView extends StatefulWidget {
  const BollingerCrossView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BollingerCrossViewState createState() => _BollingerCrossViewState();
}

class _BollingerCrossViewState extends State<BollingerCrossView> {
  late DateTime _selectedDate;
  bool isLoading = false;
  int _selectedCrossover = 1; // Default value is bullish
  List<Entry> _responseData = [];
  final SupabaseClient _supabaseClient = SupabaseClient(
    'https://zupoorksdnsivvijzsqd.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1cG9vcmtzZG5zaXZ2aWp6c3FkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxNzkwODksImV4cCI6MjA1MTc1NTA4OX0.6IsoiKMFnq7_TE7gURZaNdPwHAp-43xNGwaCyE1hX-8',
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    final response = await _supabaseClient
        .from('envelope_buy')
        .select()
        .eq('date', _selectedDate.toString())
        .eq('crossover', _selectedCrossover);

    // print(response);
    // if (response.isEmpty) {
    //   return;
    // }

    final List<dynamic> data = response;
    if (data.isNotEmpty) {
      setState(() {
        _responseData = data.map((entry) => Entry.fromJson(entry)).toList();
      });
    } else {
      setState(() {
        _responseData = [];
      });
      // No data found
      // print('No data found for the selected date and crossover.');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff5aa212),
        title: const Text(
          '⚡ Bollinger Blast ⚡',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FittedBox(
                  child: Column(
                    children: [
                      const Text(
                        'Date:',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      // const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          ).then((pickedDate) {
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDate = pickedDate;
                              });
                            }
                          });
                        },
                        child: Text(
                          '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                          style: const TextStyle(fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                ),
                FittedBox(
                  child: Column(
                    children: [
                      const Text(
                        'Crossover:',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 1,
                            groupValue: _selectedCrossover,
                            onChanged: (value) {
                              setState(() {
                                _selectedCrossover = value as int;
                              });
                            },
                          ),
                          const Text('Bullish'),
                          const SizedBox(width: 20.0),
                          Radio(
                            value: -1,
                            groupValue: _selectedCrossover,
                            onChanged: (value) {
                              setState(() {
                                _selectedCrossover = value as int;
                              });
                            },
                          ),
                          const Text('Bearish'),
                        ],
                      ),
                    ],
                  ),
                ),
                // const SizedBox(width: 20.0),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Color(0xff5aa212)),
                ),
                onPressed: isLoading ? null : _fetchData,
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text(
                        'Get Data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const Divider(),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _responseData.isNotEmpty
                        ? ListView.builder(
                            itemCount: _responseData.length,
                            itemBuilder: (context, index) {
                              final entry = _responseData[index];
                              return ListTile(
                                onTap: () async {
                                  final Uri url = Uri.parse(
                                      'https://in.tradingview.com/chart/?symbol=NSE%3A${entry.stock}');
                                  if (!await launchUrl(
                                    url,
                                    mode: LaunchMode.inAppWebView,
                                    webOnlyWindowName:
                                        kIsWeb ? '_blank' : '_self',
                                  )) {
                                    throw Exception('Could not launch $url');
                                  }
                                },
                                leading: Text("${index + 1}"),
                                title: Text(entry.stock),
                                // subtitle: Text(entry.date.toString()),
                                trailing: Text(
                                  entry.crossover == 1 ? 'Bullish' : 'Bearish',
                                  style: TextStyle(
                                    color: entry.crossover == 1
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                              "💔\nNO STOCKS FOUND.!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ),
                  ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Bolinger Blast",
    theme: ThemeData(
      fontFamily: 'Satoshi',
      primarySwatch: Colors.green,
    ),
    home: const Splash(),
  ));
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: MediaQuery.of(context).size.width * .60,
      splash: Lottie.asset('assets/icons/Animation - 1714463822927.json'),
      nextScreen: const BollingerCrossView(),
      duration: 2000,
      splashTransition: SplashTransition.scaleTransition,
    );
  }
}
