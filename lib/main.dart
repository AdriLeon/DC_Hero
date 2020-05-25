import 'dart:convert';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';
import 'dart:async';
import 'Detalles.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(),
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      title: new Text(
        'Loading...',
        style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      seconds: 5,
      navigateAfterSeconds: HomePage(),
      image: new Image.asset(
          'assets/DC_Logo.png'),
      backgroundColor: Colors.blueGrey,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 120.0,
      loaderColor: Colors.white,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>{
  Future<String> _loadData() async {
    return await rootBundle.loadString('assets/superhero');
  }

  Future<List<Heroes>> _getHero() async{
    String jsonString = await _loadData();
    var jsonData = jsonDecode(jsonString);

    List<Heroes> heroes = [];
    for (var i in jsonData) {
      Heroes DC_hero = Heroes(i["img"], i["superheroe"], i["identidad"], i["edad"], i["altura"], i["genero"], i["descripcion"]);
      heroes.add(DC_hero);
    }
    return heroes;
  }

  String Search = '';
  bool _isSearching = false;
  final Controller_search = TextEditingController();

  AudioCache audioCache;
  AudioPlayer audioPlayer;

  final music_name= "DC_music.mp3";

  @override
  void initState() {
    super.initState();

    audioCache = AudioCache();
    audioPlayer = AudioPlayer();
    var loop = 1;
    setState(() {
      audioCache.play(music_name);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        title: _isSearching ? TextField(
          decoration: InputDecoration(
            hintText: "Buscar un SuperHeroe",
            icon: Icon(Icons.search)
          ),
          onChanged: (value){
            setState(() {
              Search = value;
            });
          },
          controller: Controller_search,
        ) : Text("SuperHeroes DC Comics"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        actions: <Widget>[
          !_isSearching ? IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              Search = "";
              this._isSearching = !this._isSearching;
            });
          },) : IconButton(
            icon: Icon(Icons.cancel),
            onPressed: (){
              setState(() {
                this._isSearching = !this._isSearching;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: FutureBuilder(
            future: _getHero(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Cargando..."),
                  ),
                );
              }else{
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index){
                    return snapshot.data[index].superheroe.contains(Search) ?
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(snapshot.data[index].img.toString()),
                      ),
                      title: Text(snapshot.data[index].superheroe.toString().toUpperCase()),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerDetalles(snapshot.data[index])));
                      },
                    ) : Container();
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class Heroes {
  final String img;
  final String superheroe;
  final String identidad;
  final String edad;
  final String altura;
  final String genero;
  final String descripcion;

  Heroes(this.img, this.superheroe, this.identidad, this.edad, this.altura, this.genero, this.descripcion);
}
