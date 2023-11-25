import "package:http/http.dart" as http;
import "dart:convert";

// add this in androidManifest.xml to allow internet permission <uses-permission android:name="android.permission.INTERNET" />

//add internet permission macos:
// <!-- Required to fetch data from the internet. -->
// <key>com.apple.security.network.client</key>
// <true/>

const String ip = "http://192.168.178.20:3000/api";

Future<http.Response> getNames() async {
  final res = await http.get(Uri.parse(ip));

  if (res.statusCode == 200) {
    return res;
  } else {
    throw Error();
  }
}

// void main() async {
//   http.Response getResponse = await getNames();
//   var getData = jsonDecode(getResponse.body);

//   for (var i = 0; i < getData.length; i++) {
//     print(getData[i]);
//   }
// }
