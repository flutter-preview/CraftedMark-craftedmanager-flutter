import 'package:crafted_manager/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneSignalAPI {
  static const _url = "https://onesignal.com/api/v1/notifications";

  static const String _companyName = "CraftedManager";

  static Future<void> sendNotification(String message) async {
    var uri = Uri.parse(_url);

    var payload = {
      "included_segments": "Subscribed Users",
      "app_id": AppConfig.ONESIGNAL_APP_KEY,
      "contents": {
        "en": message,
      },
      "name": _companyName,
    };
    var headers = {
      "accept": "application/json",
      "Authorization": "Basic ${AppConfig.ONESIGNAL_REST_API_KEY}",
      "content-type": "application/json"
    };
    try {
      var result = await http.post(uri, headers: headers, body: jsonEncode(payload));

      print( result.body.toString());
    }catch(e){
      print(e);
    }

  }
}