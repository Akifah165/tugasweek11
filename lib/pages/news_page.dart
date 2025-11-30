import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<dynamic> news = [];
  DateTime? lastRefresh;

  @override
  void initState() {
    super.initState();
    fetchNews(); // ⛳ WAJIB
  }

  Future<void> fetchNews() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNews = prefs.getString('news_data');
    final cachedTime = prefs.getString('news_time');

    // Kalau cache ada → tampilkan dulu cache
    if (cachedNews != null) {
      setState(() {
        news = jsonDecode(cachedNews);
        lastRefresh = DateTime.tryParse(cachedTime ?? '');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data from Cache')),
      );
    }

    // Ambil data dari API
    try {
      final response = await http.get(
        Uri.parse("https://jsonplaceholder.typicode.com/posts"),
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedNews = jsonDecode(response.body);

        setState(() {
          news = fetchedNews;
          lastRefresh = DateTime.now();
        });

        // Simpan ke cache
        prefs.setString('news_data', jsonEncode(fetchedNews));
        prefs.setString('news_time', lastRefresh.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data from API')),
        );
      }
    } catch (_) {}
  }

  void clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('news_data');
    await prefs.remove('news_time');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("News"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNews,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearCache,
          ),
        ],
      ),
      body: news.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: news.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  news[index]['title'],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
    );
  }
}
