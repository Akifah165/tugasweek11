import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> posts = [];
  bool isLoading = true;
  String? lastRefresh;

  final apiService = ApiService();
  final localService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    loadCachedPosts();
  }

  Future<void> loadCachedPosts() async {
    String? cached = await localService.getPosts();
    lastRefresh = await localService.getLastRefresh();

    if (cached != null) {
      List jsonData = jsonDecode(cached);
      posts = jsonData.map((e) => Post.fromJson(e)).toList();
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data from Cache")));
    }

    loadFromAPI(); // tetap update API seperti semula
  }

  Future<void> loadFromAPI() async {
    try {
      List<Post> fresh = await apiService.fetchPosts();
      setState(() {
        posts = fresh;
        isLoading = false;
      });

      await localService.savePosts(
          jsonEncode(fresh.map((e) => e.toJson()).toList()));
      lastRefresh = await localService.getLastRefresh();

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Data from API")));
    } catch (e) {
      print("API error: $e");
    }
  }

  Future<void> clearCache() async {
    await localService.clearCache();
    setState(() {
      posts = [];
      lastRefresh = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Cache deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cached API Example"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => isLoading = true);
              await loadFromAPI();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: clearCache,
          )
        ],
      ),
      body: Column(
        children: [
          if (lastRefresh != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Last refresh: $lastRefresh",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final p = posts[index];
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text(p.body),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
