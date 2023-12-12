// import 'dart:ui';

import 'package:flutter/material.dart';

import "package:http/http.dart" as http;
import "dart:convert";

// this link explains how to make child setState of parent widget... its amazing
// remember this, btw solution also in archive.org
// https://www.appsloveworld.com/flutter/100/26/how-to-update-the-state-of-parent-widget-from-its-child-widget-while-also-updatin

const double tableBorderWidth = 1;
const Color tableBorderColor = Color.fromARGB(150, 182, 182, 182);

const double listPadding = 10;
int? listLength = 0; // can be int or null
// http://192.168.178.20:3000/api
// http://192.168.178.20:3000
String ip = "";
String onlineCheckIp = "";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  callbackSetState() {
    setState(() {});
  }

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
              backgroundColor: const Color.fromARGB(255, 175, 171, 226),
              title: const Text("Edit Namelist!"),
              foregroundColor: Colors.black,
              actions: [
                SettingsWidget(
                  callbackSetState: callbackSetState,
                )
              ],
            ),
            // floatingActionButton: const SendButton(),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: Container(
              //dont do const because then settingswidget callbackSetState() wont affect this
              // ignore: prefer_const_constructors
              child: ListToDisplay(),
            )));
  }
}

class SettingsWidget extends StatefulWidget {
  Function callbackSetState;
  SettingsWidget({super.key, required this.callbackSetState});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  var settingsController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        _errorText = null;
        settingsController.text = onlineCheckIp.replaceAll("http://", "");
        showAdaptiveDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: ((stfcontext, stfState) {
                  return AlertDialog(
                    scrollable: true,
                    title: const Center(child: Text("Settings")),
                    content: Form(
                        child: TextFormField(
                      enableInteractiveSelection: true,
                      enableSuggestions: false,
                      autofocus: true,
                      controller: settingsController,
                      decoration: InputDecoration(
                        errorText: _errorText,
                        labelText: "IP of server",
                        hintText: "e.g. 192.168.178.20:3000",
                      ),
                    )),
                    actions: [
                      FloatingActionButton(
                          onPressed: () {
                            //here just save input to ip & close settings
                            if (settingsController.text.isEmpty) {
                              // print("ip input can't be empty");
                              _errorText = "Can't be empty";
                              stfState(() {});
                              return;
                            } else {
                              _errorText = null;
                            }

                            // need to impliment this to reconnect with new ip
                            // i think ill just save it in the vars being used and
                            // somehow make everything setstate

                            // idk know anymorhe this is too confusion whyyyyyyyyy
                            var newIP = settingsController.text.trim();
                            onlineCheckIp = "http://$newIP";
                            ip = "$onlineCheckIp/api";

                            // print(ip);
                            // print(onlineCheckIp);
                            widget.callbackSetState();
                            Navigator.pop(context);
                          },
                          child: const Text("Save"))
                    ],
                  );
                }),
              );
            });
      },
    ));
  }
}

class FirstTimeSettings extends StatefulWidget {
  Function firstTimeSetState;
  FirstTimeSettings({super.key, required this.firstTimeSetState});

  @override
  State<FirstTimeSettings> createState() => _FirstTimeSettingsState();
}

class _FirstTimeSettingsState extends State<FirstTimeSettings> {
  var textController = TextEditingController();
  String? _errorText;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (stfcontext, stfState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Text(
                  "Insert IP adress of the server",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Center(
                  child: Form(
                    canPop: true,
                    child: TextFormField(
                      autocorrect: false,
                      controller: textController,
                      decoration: InputDecoration(
                          errorText: _errorText,
                          border: const OutlineInputBorder(),
                          labelText: "IP of server",
                          hintText: "e.g. 192.168.178.20:3000"),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: FloatingActionButton.extended(
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                    onPressed: () {
                      if (textController.text.isEmpty) {
                        _errorText = "Can't be empty";
                        stfState((() {}));
                        return;
                      } else {
                        _errorText = null;
                      }
                      var newIP = textController.text.trim();
                      onlineCheckIp = "http://$newIP";
                      ip = "$onlineCheckIp/api";

                      widget.firstTimeSetState();
                    }),
              )
            ],
          ),
        );
      },
    );
  }
}

Future<List> getData() async {
  if (ip == "") {
    return [
      {"error": "Invalid argument(s): No host specified in URI", "code": 1}
    ];
  }
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

// Future<bool> isOnline() async {
//   var res = await http.get(Uri.parse(onlineCheckIp));
//   if (res.statusCode == 200) {
//     var getData = jsonDecode(res.body);
//     if (getData?.online == null) {
//       return false;
//     }
//     return true;
//   } else {
//     throw Error();
//   }
// }

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
  firstTimeSetState() {
    setState(() {});
  }

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
        //print(onlineCheckIp);
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
                      Text(
                        "Server is online - Loading...",
                        textAlign: TextAlign.center,
                      )
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
                                "If stuck here, check if the server is offline & turn it on",
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                  "Alternatively, make sure IP of the server is correct",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(150, 0, 0, 0)),
                                ),
                              )
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
            //print(snapshot.error);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                        textAlign: TextAlign.center,
                        "check the settings & make sure the ip of the server is correct!"),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                        style: TextStyle(color: Color.fromARGB(150, 0, 0, 0)),
                        textAlign: TextAlign.center,
                        "Note:\n Currently this only works on a local network, meaning that this device and the Raspberry Pi/screen have to be connected to the same network!"),
                  ),
                ],
              ),
            );
          } else {
            //handle if function returns custom error
            //print(snapshot.data?[0]["code"]);
            if (snapshot.data?[0]["code"] == 1) {
              return FirstTimeSettings(firstTimeSetState: firstTimeSetState);
            }
            if (snapshot.data == null || snapshot.data?.isEmpty == true) {
              return const Text("Data recieved is empty");
            }
            listLength = snapshot.data?.length;

            return Scaffold(
              //this shit stupid af i cant put this inside a seperate widget for some reason
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(right: listPadding),
                child:
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
                          //removes error text for next time dialog is opened
                          _errorText = null;

                          showAdaptiveDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (stfcontext, stfState) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title:
                                        const Center(child: Text("Add name")),
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
                                          icon:
                                              const Icon(Icons.account_circle)),
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
                                                //print("Can't be empty");
                                                stfState(() {
                                                  _errorText = "Can't be empty";
                                                });

                                                return;
                                              } else {
                                                _errorText = null;
                                              }

                                              //sftState sets the state for StatefulBuilder
                                              //whilst setState sets state for entire widget
                                              //(aka. the FutureBuilder)
                                              var nameToAdd =
                                                  textController.text;
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
                          );
                        },
                        child: const Icon(Icons.add)),
                  ),
                ]),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,

              //this is the list
              body: Scrollbar(
                interactive: true,
                thumbVisibility: true,
                thickness: 7,
                radius: const Radius.circular(5),
                child: ListView.builder(
                  //this padding is a stupid agdgsdfjlshkf solution
                  // but i am bad at ui so itttl do
                  padding: const EdgeInsets.fromLTRB(
                      listPadding, listPadding, listPadding, 150),
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
                          // padding: EdgeInsets.only(right: 50),
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
              ),
            );
          }
        }
      },
    );
  }
}

//testing
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
