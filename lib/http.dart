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

Future addNames() async {
  final res = await http.post(Uri.parse(ip),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "add",
        "names": ["tiM", "tom", "toby"],
      }));

  if (res.statusCode == 200) {
    var getData = jsonDecode(res.body);
    return Future.value(getData);
  } else {
    throw Future.value(Error());
  }
}

Future removeNames(bodyObject) async {
  final res = await http.post(Uri.parse(ip),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bodyObject));

  if (res.statusCode == 200) {
    var getData = jsonDecode(res.body);
    return Future.value(getData);
  } else {
    throw Future.value(Error());
  }
}

void main() async {
  //print(await addNames());
  //print(await removeNames());

  // http.Response getResponse = await getNames();
  // var getData = jsonDecode(getResponse.body);

  // for (var i = 0; i < getData.length; i++) {
  //   print(getData[i]);
  // }
}
