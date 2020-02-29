import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Tarefas',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List _toDoList = [];

  @override
  void initState() {
    super.initState();
    _readData().then((data){
      setState(() {
        _toDoList = json.decode(data);  
      });
    });
  }
  final todocontroler = TextEditingController();
  void _addToDo(){
     setState(() {
        Map<String, dynamic> newTodo = Map();
      newTodo["title"] = (todocontroler.text);
      todocontroler.text = "";
      newTodo["ok"] = false;
      _toDoList.add(newTodo);
      _saveData();
     });
  }

  Map<String, dynamic> _lastRemoved;

  int _lastRemovedPos;

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));

    setState(() { 
       _toDoList.sort((a, b){
      if(a["ok"] && !b["ok"]) return 1;
      else if(!a["ok"] && b["ok"]) return -1;
      else if(a["ok"] == b["ok"]) return 0;
    });

    _saveData();
    });

    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 2, left: 20, right: 20, bottom: 2),
          child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: todocontroler,
                    decoration: InputDecoration(
                    labelText: "Nova Tarefa",
                    ),
                  ),
                ),
                RaisedButton(
                  color: Colors.blue,
                  child: Text("Add"),
                  textColor: Colors.white,
                  onPressed: (){_addToDo();},
                ),
              ],
            ),
            Expanded(
                  child: RefreshIndicator(
                    child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    itemCount:_toDoList.length,
                    itemBuilder: buildItem
                  ),
                  onRefresh: _refresh,
                  )
                )
          ],
      ),
        ),
    );
  }

Widget buildItem(context, index){
      return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0),
            child: Icon(Icons.delete, color: Colors.white,),
          ),
        ),
        child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(child: Icon(
          _toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
            setState(() {
           _toDoList[index]['ok'] = c;
            _saveData();
              });
            },
           ),
        onDismissed: (direction){ 
          setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemoved['title']}\" removida"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _toDoList.insert(_lastRemovedPos, _lastRemoved);
                _saveData();
                });
              },
               ),
               duration: Duration(seconds: 2),
          );
            Scaffold.of(context).showSnackBar(snack);
          }); 
          });
} 


  
Future<File> _getFile() async{
  final diretory = await getApplicationDocumentsDirectory();
  return File("${diretory.path}/data.json");
}
 
Future<File> _saveData() async{
  String data = json.encode(_toDoList);
  final file = await _getFile();
  return file.writeAsString(data);
}

Future<String> _readData() async{
  try{
    final file = await _getFile();
    return file.readAsString();
  } catch(e){
    return null;
  }
}

}
