import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LearnFirebase extends StatefulWidget {
  const LearnFirebase({Key? key}) : super(key: key);

  @override
  _LearnFirebaseState createState() => _LearnFirebaseState();
}

class _LearnFirebaseState extends State<LearnFirebase> {
  List<String> listStrings = <String>["Nenhum registro carregado"];
  late Uri url;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    url = Uri.parse(
        "https://gym-app-99d1e-default-rtdb.firebaseio.com/words.json");
    _getInformationfromBack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Center(
          child: RefreshIndicator(
            onRefresh: () => _getInformationfromBack(),
            child: ListView(
              children: [
                TextFormField(
                  controller: _controller,
                  decoration:
                      InputDecoration(labelText: "Insira uma palavra aqui"),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: _addStringToBack,
                  child: Text("Gravar no Firebase"),
                ),
                (listStrings.isEmpty)
                    ? Text(
                        "Nenhum elemento carregado",
                        textAlign: TextAlign.center,
                      )
                    : Column(
                        children: listStrings.map((s) => Text(s)).toList(),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getInformationfromBack() {
    return http.get(url).then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> map = json.decode(response.body);
        List<String> strings = [];
        map.forEach((key, value) {
          strings.add(map[key] as String);
        });
        setState(() {
          listStrings = strings;
        });
      } else {
        throw Exception('Failed to load data from Firebase');
      }
    }).catchError((error) {
      // Tratar erros de rede ou comunicação
      throw Exception('Failed to load data from Firebase');
    });
  }

  void _addStringToBack() {
    final word = _controller.text;
    http.post(url, body: json.encode({"word": word})).then((response) {
      if (response.statusCode == 200) {
        // Sucesso - você pode lidar com a resposta aqui
        final snackBar =
            SnackBar(content: Text('A palavra foi gravada com sucesso!'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          listStrings.add(word);
          _controller.clear();
        });
      } else {
        // Tratar erros ou respostas inesperadas
        throw Exception('Failed to save data to Firebase');
      }
    }).catchError((error) {
      // Tratar erros de rede ou comunicação
      throw Exception('Failed to save data to Firebase');
    });
  }
}
