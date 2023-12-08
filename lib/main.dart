import 'dart:ui';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import "dart:convert";

const double tableBorderWidth = 1;
const Color tableBorderColor = Color.fromARGB(150, 182, 182, 182);

const double listPadding = 10;
int? listLength = 0; // can be int or null
const String ip = "http://192.168.178.20:3000/api";
const String onlineCheckIp = "http://192.168.178.20:3000";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.grey,
            useMaterial3: true),
        home: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Color.fromARGB(255, 175, 171, 226),
              title: const Text("Edit Namelist!"),
              foregroundColor: Colors.black,
            ),
            // floatingActionButton: const SendButton(),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: Container(
              child: const ListToDisplay(),
            )));
  }
}

Future<List> getData() async {
  var res = await http.get(Uri.parse(ip));
  if (res.statusCode == 200) {
    var getData = jsonDecode(res.body);
    //print(getData);

    return Future.value(getData);
  } else {
    throw Future.value(Error());
  }
}

Future removeNames(bodyObject) async {
  var res = await http.post(Uri.parse(ip),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(bodyObject));

  if (res.statusCode == 200) {
    var getData = jsonDecode(res.body);
    return Future.value(getData);
  } else {
    throw Future.value(Error());
  }
}

Future addNames(bodyObject) async {
  var res = await http.post(
    Uri.parse(ip),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(bodyObject),
  );

  if (res.statusCode == 200) {
    var getdata = jsonDecode(res.body);
    return Future.value(getdata);
  } else {
    throw Future.value(Error());
  }
}

Future<bool> isOnline() async {
  var res = await http.get(Uri.parse(onlineCheckIp));
  if (res.statusCode == 200) {
    var getData = jsonDecode(res.body);
    if (getData?.online == null) {
      return false;
    }
    return true;
  } else {
    throw Error();
  }
}

// class SendButton extends StatefulWidget {
//   const SendButton({super.key});

//   @override
//   State<SendButton> createState() => SendButtonState();
// }

// class SendButtonState extends State<SendButton> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
//       FloatingActionButton(
//           child: const Icon(Icons.refresh_rounded),
//           onPressed: () {
//             return setState(() {});
//           }),
//       Padding(
//         padding: const EdgeInsets.only(top: 10),
//         child: FloatingActionButton(
//             onPressed: () {}, child: const Icon(Icons.add)),
//       ),
//     ]);
//   }
// }

class ListToDisplay extends StatefulWidget {
  const ListToDisplay({super.key});

  @override
  State<ListToDisplay> createState() => _ListToDisplayState();
}

class _ListToDisplayState extends State<ListToDisplay> {
  //got it from https://stackoverflow.com/a/70951162
  Stream<http.Response> isOnlineStream() async* {
    yield* Stream.periodic(const Duration(seconds: 5), (_) {
      var i;
      setState(() {
        i = http.get(Uri.parse(onlineCheckIp));
      }); // added this ... idk why this works Flutter is stoopid
      return i;
    }).asyncMap((event) async => await event);
  }

//use this to retrieve text from text field
  var textController = TextEditingController();

  String? _errorText;

  // @override
  // void dispose() {
  //   //clean up the controller when widget is disposed
  //   textController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    //no to make this a streamBuilder. Just add a refresh overlay button along with the add name button
    return FutureBuilder(
      future: getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // this automatically reconnects when when server is turned back on
          // & also happens when waiting for a response. 2 for 1
          return StreamBuilder(
            stream: isOnlineStream(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                //this only gets called when we are waiting for response from server, eventhough they are connected
                // basically this gets shown when response is waiting for database to finish doing database stuff
                return const Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator.adaptive(),
                      Text("Server is online - Loading...")
                    ],
                  ),
                );
              } else {
                return const Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 70,
                          width: 70,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 5,
                          )),
                      Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Text("Loading..."),
                              Text(
                                  "If stuck here, check if the server is offline & turn it on")
                            ],
                          ))
                    ],
                  ),
                );
              }
            },
          );
        } else {
          if (snapshot.hasError) {
            return Center(
              child: Text("error ${snapshot.error}"),
            );
          } else {
            if (snapshot.data == null || snapshot.data?.isEmpty == true) {
              return const Text("Data recieved is empty");
            }
            listLength = snapshot.data?.length;

            return Scaffold(
              //this shit stupid af i cant put this inside a seperate widget for some reason
              floatingActionButton:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                FloatingActionButton(
                    // refresh list
                    child: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      setState(() {});
                    }),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FloatingActionButton(
                      //add to list
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              scrollable: true,
                              title: const Center(child: Text("Add name")),
                              //form inside the alert dialog
                              content: Form(
                                  child: TextFormField(
                                enableInteractiveSelection: true,
                                enableSuggestions: true,
                                autofocus: true,
                                controller: textController,
                                decoration: InputDecoration(
                                    errorText: _errorText,
                                    labelText: "Name",
                                    // errorText: "Can't be empty",
                                    icon: const Icon(Icons.account_circle)),
                              )),
                              // buttons inside the alertdialog
                              actions: [
                                SizedBox(
                                  width: 80,
                                  child: FloatingActionButton(
                                      //here send names to add to the server
                                      onPressed: () {
                                        //print(textController.text);
                                        if (textController.text.isEmpty) {
                                          print("Can't be empty");
                                          _errorText = "Can't be empty";
                                          setState(() {});
                                          return;
                                        }

                                        var nameToAdd = textController.text;
                                        var addNamesObj = {
                                          "action": "add",
                                          "names": [nameToAdd]
                                        };
                                        setState(() {
                                          addNames(addNamesObj);
                                        });
                                        Navigator.pop(context);
                                        textController.clear();
                                      },
                                      child: const Text("Submit")),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.add)),
                ),
              ]),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,

              //this is the list
              body: ListView.builder(
                padding: const EdgeInsets.all(listPadding),
                itemCount: listLength,
                itemBuilder: (BuildContext context, int index) {
                  //print(snapshot.data?[index]["name"]);

                  return Container(
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Color.fromARGB(20, 0, 0, 0)))),
                    child: ListTile(
                      onTap: () {},
                      title: Text("${snapshot.data?[index]["name"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // var itemToDelete = snapshot.data?[index];
                          if (snapshot.data?.isNotEmpty == true) {
                            var deleteBodyObj = {
                              "action": "delete",
                              "names": [index + 1],
                            };
                            // removeNames(deleteBodyObj);
                            setState(() {
                              removeNames(deleteBodyObj);
                            });
                            // send to server, then recieve the new list & display it
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        }
      },
    );
  }
}

class EditableList extends StatelessWidget {
  const EditableList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(listPadding),
      itemCount: listLength,
      itemBuilder: (BuildContext context, int index) => ListTile(
        onTap: () {},
        title: const Text("hello"),
        subtitle: const Text("General Kenobi!"),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {},
        ),
      ),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
