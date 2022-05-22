import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radio_player/flutter_radio_player.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:transparent_image/transparent_image.dart';

class Meta {
  final String musicTitle;
  final String musicArtist;
  final String musicUrl;
  final String fieldTitle;
  final String fieldArtist;
  final String fieldUrl;
  final String vocalTitle;
  final String vocalArtist;
  final String vocalUrl;

  Meta({
    required this.musicTitle,
    required this.musicArtist,
    required this.musicUrl,
    required this.fieldTitle,
    required this.fieldArtist,
    required this.fieldUrl,
    required this.vocalTitle,
    required this.vocalArtist,
    required this.vocalUrl,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
        musicTitle: json['musicTitle'],
        musicArtist: json['musicArtist'],
        musicUrl: json['musicUrl'],
        fieldTitle: json['fieldTitle'],
        fieldArtist: json['fieldArtist'],
        fieldUrl: json['fieldUrl'],
        vocalTitle: json['vocalTitle'],
        vocalArtist: json['vocalArtist'],
        vocalUrl: json['vocalUrl']
    );
  }
}


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final playerState = FlutterRadioPlayer.flutter_radio_playing;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin, WidgetsBindingObserver {

  double volume = 1.0;
  FlutterRadioPlayer _flutterRadioPlayer = new FlutterRadioPlayer();

  final StreamController<Meta>? metaController = StreamController();
  late final Stream<Meta>? metaStream = metaController?.stream;

  late final AnimationController _controller = AnimationController(duration: Duration(seconds: 2), vsync: this);
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0)
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

  bool _visible = false;

  void _toggle() {
    setState(() {
      _visible = !_visible;
    });
  }
  Future<bool> launchUrl(
      Uri url, {
        LaunchMode mode =  LaunchMode.externalApplication,
        WebViewConfiguration webViewConfiguration = const WebViewConfiguration(),
        String? webOnlyWindowName,
      }) async {
    final bool isWebURL = url.scheme == 'http' || url.scheme == 'https';
    if (mode == LaunchMode.inAppWebView && !isWebURL) {
      throw ArgumentError.value(url, 'url',
          'To use an in-app web view, you must provide an http(s) URL.');
    }
    return await launchUrlString(
      url.toString(),
      mode: mode,
      webViewConfiguration: webViewConfiguration,
      webOnlyWindowName: webOnlyWindowName,
    );
  }
  _launchUrl(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _portraitMode(){
    return Stack(
      children: [
        Center(
          heightFactor: 1.0,
          child: Padding(
            padding: EdgeInsets.all(45),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Image(image: AssetImage("assets/millicent_portrait_dark.jpg")),
                  ),
              ],
            )
          )
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                StreamBuilder<Meta>(
                    stream: metaStream,
                    initialData: Meta(musicTitle: "silence", musicArtist: "silence", fieldTitle: "silence", fieldArtist: "silence", vocalTitle: "silence", vocalArtist: "silence", vocalUrl: '', fieldUrl: '', musicUrl: ''),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot.data.runtimeType);
                        var processed = snapshot.data != null? snapshot.data:Meta(musicTitle: "silence", musicArtist: "silence", fieldTitle: "silence", fieldArtist: "silence", vocalTitle: "silence", vocalArtist: "silence", fieldUrl: '', musicUrl: '', vocalUrl: '');
                        var p = processed!;
                        print(p);
                        var musicTitle = p.musicTitle.toString();
                        var musicArtist = p.musicArtist.toString();
                        var musicUrl = p.musicUrl.toString();
                        var vocalTitle = p.vocalTitle.toString();
                        var vocalArtist = p.vocalArtist.toString();
                        var vocalUrl = p.vocalUrl.toString();
                        var fieldTitle = p.fieldTitle.toString();
                        var fieldArtist = p.fieldArtist.toString();
                        var fieldUrl = p.fieldUrl.toString();
                        return Column(
                            children:  [
                              Column(
                                children: [
                                  vocalTitle != "" && vocalTitle != "silence"
                                      ?SlideTransition(
                                    position: _offsetAnimation,
                                    child: Card(
                                        elevation: 1,
                                        color:Color.fromRGBO(84, 146, 165, 1.0),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Color(
                                                0xff124250)),
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:[
                                            InkWell(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                  child: ListTile(
                                                    tileColor: Colors.transparent,
                                                    title: Text('''$vocalArtist''', textAlign: TextAlign.left, style: TextStyle(fontSize: 18), maxLines: 1),
                                                    subtitle: Text('''$vocalTitle\nVocal''', textAlign: TextAlign.left,style: TextStyle(fontSize: 15), maxLines: 2),
                                                    trailing: Icon(Icons.search,color: Colors.amber[400],size: 30.0),
                                                  ),
                                                ),
                                                ],
                                              ),
                                              onTap: () {
                                                final uri = Uri.parse("$vocalUrl");
                                                _launchUrl(uri);
                                              }
                                            )
                                          ],
                                        )
                                    ),
                                  )
                                      :SizedBox.shrink(),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  musicTitle != "" && musicTitle != "silence"
                                      ?SlideTransition(position: _offsetAnimation,
                                    child: Card(
                                        color:Color.fromRGBO(84, 146, 165, 1.0),
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Color(
                                                0xff124250)),
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:[
                                            InkWell(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                  child: ListTile(
                                                    tileColor: Colors.transparent,
                                                    title: Text('''$musicArtist''', textAlign: TextAlign.left, style: TextStyle(fontSize: 18), maxLines: 1),
                                                    subtitle: Text('''$musicTitle\nMusic''', textAlign: TextAlign.left,style: TextStyle(fontSize: 15), maxLines: 2),
                                                    trailing: Icon(Icons.search,color: Colors.amber[500],size: 30.0),
                                                  ),
                                                ),
                                                ],
                                              ),
                                              onTap: () {
                                                final url = Uri.parse("$musicUrl");
                                                _launchUrl(url);
                                              },
                                            )
                                          ],
                                        )
                                    ),
                                  ):SizedBox.shrink(),
                                  fieldTitle != "" && fieldTitle != "silence"
                                      ?SlideTransition(position: _offsetAnimation,
                                    child: Card(
                                        elevation: 1,
                                        color:Color.fromRGBO(84, 146, 165, 1.0),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Color(
                                                0xff124250)),
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children:[
                                            InkWell(
                                              child: Row(
                                                children:[Expanded(
                                                  child: ListTile(
                                                    tileColor: Colors.transparent,
                                                    title: Text('''$fieldArtist''', textAlign: TextAlign.left, style: TextStyle(fontSize: 18), maxLines: 1),
                                                    subtitle:Text('''$fieldTitle\nField Recording''', textAlign: TextAlign.left, style: TextStyle(fontSize: 15), maxLines: 2),
                                                    trailing: Icon(Icons.search,color: Colors.amber[600],size: 30.0),
                                                  ),
                                                ),]
                                              ),
                                              onTap: () {
                                                final url = Uri.parse("$fieldUrl");
                                                _launchUrl(url);
                                              },
                                            )
                                          ],
                                        )
                                    ),
                                  ):SizedBox.shrink(),
                                ],
                              ),
                            ]
                        );

                      } else if (snapshot.hasError){
                        return Text('{$snapshot.error}');
                      }
                      return const CircularProgressIndicator();
                    }),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                margin: const EdgeInsets.all(35.0),
                child: SingleChildScrollView(
                  child: Center(
                      child:SizedBox(
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "The ‘millicent’ Manifesto\n\n",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, )
                                    ),
                                    TextSpan(
                                      text: "1) To view the existence of the internet as a positive opportunity towards the uniting of humanity.\n\n2) To work towards the unity of humanity through the promotion of music, storytelling, poetry and sound design, from all languages and cultures.\n\n3) To promote an existence beyond the barriers constructed through contemporary political notions of national borders, through the medium of radio.\n\n4) To promote a sense of all humanity being equal. Regardless of age, race, gender, ethnicity or geographical location.\n\n5) To respect and promote the further understanding of the importance of the co-existence of differing belief systems.\n\n6) To broadcast, the very best audio quality content, celebrating the rich diversity of humanity’s cultural achievements, and to make this content available to all.\n\n7) To consider cultural diversity a positive asset.\n\n8) To educate, entertain and inform.\n\n9) To celebrate the contribution of the gift of creativity to humanity’s well being\n",
                                    )
                                  ]
                              ))
                      )
                  ),
                )
            ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver((this));
    _controller.dispose();
    metaController?.close();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    initRadioService();
    Future.delayed(const Duration(milliseconds: 3000), ()
    {
      initSse();
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      initSse();
    }
  }

  Future<void> initSse() async {
    var url = Uri.parse('http://millicent.org/api/backgroundplaylists?filter=%7B%22limit%22%3A1%2C%20%22order%22%3A%20%22id%20DESC%22%20%7D');
    http.Response res = await http.get(url);
    var j = jsonDecode(res.body);

    var muT = j[0]["music"].split("by")[0].toString().trim();
    var muA = j[0]["music"].split("by")[1].toString().trim();
    var muUrl = j[0]["music_url"].toString().trim();
    var fiT = j[0]["field"].split("by")[0].toString().trim();
    var fiA = j[0]["field"].split("by")[1].toString().trim();
    var fiUrl = j[0]["field_url"].toString().trim();
    var voT = j[0]["vocal"].split("by")[0].toString().trim();
    var voA = j[0]["vocal"].split("by")[1].toString().trim();
    var voUrl = j[0]["vocal_url"].toString().trim();

    var x = Meta(musicTitle: muT, musicArtist: muA, fieldTitle: fiT, fieldArtist: fiA, vocalTitle: voT, vocalArtist: voA, fieldUrl: fiUrl, musicUrl: muUrl, vocalUrl: voUrl);

    metaController?.sink.add(x);

    SSEClient.subscribeToSSE(
        url: "https://millicent.org/api/backgroundplaylists/change-stream?_format=event-stream",
        header: {
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache"
        }).listen((event) async {

          if (event.data != "") {
            try {
              Map<String, dynamic> json = await jsonDecode(event.data!);
              var muT = json["data"]["music"].split("by")[0].toString().trim();
              var muA = json["data"]["music"].split("by")[1].toString().trim();
              var muUrl = json["data"]["music_url"].toString().trim();
              var fiT = json["data"]["field"].split("by")[0].toString().trim();
              var fiA = json["data"]["field"].split("by")[1].toString().trim();
              var fiUrl = json["data"]["field_url"].toString().trim();
              var voT = json["data"]["vocal"].split("by")[0].toString().trim();
              var voA = json["data"]["vocal"].split("by")[1].toString().trim();
              var voUrl = json["data"]["vocal_url"].toString().trim();
              var m = Meta(musicTitle: muT, musicArtist: muA, musicUrl: muUrl, fieldTitle: fiT, fieldArtist: fiA, vocalTitle: voT, vocalArtist: voA, vocalUrl: voUrl, fieldUrl: fiUrl);
              metaController?.sink.add(m);
            } on FormatException catch (_){
              print("Json Parsing Error");
            }
          }
    });
  }

  Future<void> initRadioService() async {
    try {
      await _flutterRadioPlayer.init(
        "millicent Audio Mirror",
        "Live",
        "https://radio.millicent.org/live/live.m3u8",
        "true",
      );
    } on PlatformException {
      print("Exception occurred while trying to register the services.");
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xff124250),
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Color(0xff0d2f39),

            // Status bar brightness (optional)
            statusBarIconBrightness: Brightness.light, // For Android (dark icons)
            statusBarBrightness: Brightness.dark, // For iOS (dark icons)
          ),
          toolbarHeight: 10,
          elevation: 0,
          backgroundColor: Color(0xff0d2f39),
          title: Column(
              children: [
                //Image.asset("assets/radio_beyond_borders.jpg", fit: BoxFit.scaleDown),
                //new Text("millicent Audio Mirror", style: TextStyle(color: Colors.black54, fontSize: 25,)),
                SizedBox.shrink(),
              ],
          ),
          flexibleSpace: Container(
            color: Color(0xffe3dfb2),
            child: SizedBox(height: 24),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(
              color: Color(0xff0d2f39),
              height: 1,
            )
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Color(0xb067d216),
            elevation: 1,
            onPressed: () async {
              await _flutterRadioPlayer.playOrPause();
            },
            label: Row(
              children: [
                StreamBuilder(
                stream: _flutterRadioPlayer.isPlayingStream,
                initialData: widget.playerState,
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  String returnData = snapshot.data!;
                  print("object data: " + returnData);
                  switch (returnData) {
                    case FlutterRadioPlayer.flutter_radio_stopped:
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              await initRadioService();
                            },
                            icon: Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _flutterRadioPlayer.stop();
                            },
                            icon: Icon(Icons.stop),
                          )
                        ],
                      );
                    case FlutterRadioPlayer.flutter_radio_loading:
                      return Text("Loading stream...");
                    case FlutterRadioPlayer.flutter_radio_error:
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        child: Text("Retry ?"),
                        onPressed: () async {
                          await initRadioService();
                        },
                      );
                    default:
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              print("button press data: " +
                                  snapshot.data.toString());
                              await _flutterRadioPlayer.playOrPause();
                            },
                            icon: snapshot.data ==
                                FlutterRadioPlayer.flutter_radio_playing
                                ? Icon(Icons.pause)
                                : Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _flutterRadioPlayer.stop();
                            },
                            icon: Icon(Icons.stop),
                          )
                        ],
                      );
                  }
                },
              ),
              ],
            )
        ),
        body: _portraitMode(),
        bottomNavigationBar: BottomAppBar(
          elevation: 3,
          color: Color(0xff0d2f39),
          notchMargin: 3,
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(),
              StadiumBorder(
                side: BorderSide()
              ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: new Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        child:IconButton(
                          icon: Icon(
                            Icons.notes_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final uri = Uri.parse("https://millicent.org");
                            launchUrl(uri);
                          },
                        ),
                      )
                    ),
                    Spacer(),
                    Expanded(
                        flex: 1,
                        child:IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                          onPressed: _toggle,
                        ),
                    ),
                  ],
                ),
              ),
            ],
          )
        )
      ),
    );
  }
}


