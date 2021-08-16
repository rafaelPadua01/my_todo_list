import 'package:flutter/material.dart';
import 'view/list.dart';
import 'view/form.dart';
import 'view/checked.dart';
import 'view/groups.dart';
import 'view/formGroup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Lista de Tarefas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),

          //Botões de ação do appBar
          //este botão deve chamar uma nova pagina
          //esta nova página deverá carregar uma nova lista
          //esta nova lista deverá conter todos os afazeres 'completos'
          actions: <Widget>[
            //Botão 'nexxt page'
            IconButton(
              icon: Icon(Icons.navigate_next),
              tooltip: 'Go to the next page...',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Itens checados...'),
                      ),
                      body: Center(
                        child: ListChecked(),
                      ),
                    );
                  },
                ));
              },
            ),
          ],
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              icon: Icon(Icons.how_to_reg_sharp),
            ),
            Tab(
              icon: Icon(Icons.group_add_sharp),
            ),
            Tab(
              icon: Icon(Icons.create_sharp),
            ),
          ]),
        ),
        //Buttom Drawer
        //hamburger type
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              //Cabeçalho do drawer
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                ),
                child: const Text(
                  'Bem Vindo...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.save_sharp),
                title: Text('Salvos'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('Listas Salvas'),
                        ),
                        body: Center(
                          child: GridGroups(),
                        ),
                      );
                    },
                  ));
                },
              ),
            ],
          ),
        ),

        body: TabBarView(children: <Widget>[
          Center(child: ListTodo()),
          Center(child: FormGroup()),
          Center(child: FormTodo()),
        ]
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            ),
      ),
    );
  }
}
