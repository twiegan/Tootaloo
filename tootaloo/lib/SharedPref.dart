import 'package:tootaloo/AppUser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {

  // checking user
  static Future<AppUser> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("id");
    String? username = prefs.getString("username");
    AppUser user = AppUser(username: username, id: id);
    return user;
  }

// set AuthToken once user login completed
  static Future<bool> setId(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", id);
    return true;
  }

// set UserName once user login completed
  static Future<bool> setUsername(String username) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("username", username);
    return true;
  }


}