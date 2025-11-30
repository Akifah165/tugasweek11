import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String keyPosts = "cached_posts";
  static const String keyLastRefresh = "last_refresh";

  Future<void> savePosts(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPosts, jsonString);
    await prefs.setString(keyLastRefresh, DateTime.now().toString());
  }

  Future<String?> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPosts);
  }

  Future<String?> getLastRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLastRefresh);
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyPosts);
    await prefs.remove(keyLastRefresh);
  }
}
