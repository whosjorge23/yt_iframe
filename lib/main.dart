import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:yt_iframe/video_list.dart';

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
      debugShowCheckedModeBanner: false,
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
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

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
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;
  bool isVisible = false;

  final List<String> _ids = [
    '9AhqDiARQMQ',
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: _ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
        showLiveFullscreenButton: true,
        controlsVisibleAtStart: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      },
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.purple,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              log('Settings Tapped!');
            },
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          _showSnackBar('Next Video Started!');
        },
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          // leading: Padding(
          //   padding: const EdgeInsets.only(left: 12.0),
          //   child: Image.asset(
          //     'assets/ypf.png',
          //     fit: BoxFit.fitWidth,
          //   ),
          // ),
          title: Text(
            'Youtube Player Flutter',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                isVisible = !isVisible;
                setState(() {});
                print(isVisible);
              },
              //     () => Navigator.push(
              //   context,
              //   CupertinoPageRoute(
              //     builder: (context) => VideoList(),
              //   ),
              // ),
            ),
          ],
        ),
        body: ListView(
          children: [
            isVisible ? _space : SizedBox.shrink(),
            isVisible
                ? TextField(
                    enabled: _isPlayerReady,
                    controller: _idController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter youtube \<video id\> or \<link\>',
                      fillColor: Colors.purple.withAlpha(20),
                      filled: true,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.purple,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _idController.clear(),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            isVisible ? _loadCueButton('Search') : SizedBox.shrink(),
            isVisible ? _space : SizedBox.shrink(),
            player,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row(
                  //   children: [
                  //     _loadCueButton('LOAD'),
                  //     const SizedBox(width: 10.0),
                  //     _loadCueButton('CUE'),
                  //   ],
                  // ),
                  _space,
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     IconButton(
                  //       icon: const Icon(Icons.skip_previous),
                  //       onPressed: _isPlayerReady
                  //           ? () => _controller.load(_ids[
                  //               (_ids.indexOf(_controller.metadata.videoId) -
                  //                       1) %
                  //                   _ids.length])
                  //           : null,
                  //     ),
                  //     IconButton(
                  //       icon: Icon(
                  //         _controller.value.isPlaying
                  //             ? Icons.pause
                  //             : Icons.play_arrow,
                  //       ),
                  //       onPressed: _isPlayerReady
                  //           ? () {
                  //               _controller.value.isPlaying
                  //                   ? _controller.pause()
                  //                   : _controller.play();
                  //               setState(() {});
                  //             }
                  //           : null,
                  //     ),
                  //     IconButton(
                  //       icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                  //       onPressed: _isPlayerReady
                  //           ? () {
                  //               _muted
                  //                   ? _controller.unMute()
                  //                   : _controller.mute();
                  //               setState(() {
                  //                 _muted = !_muted;
                  //               });
                  //             }
                  //           : null,
                  //     ),
                  //     FullScreenButton(
                  //       controller: _controller,
                  //       color: Colors.blueAccent,
                  //     ),
                  //     IconButton(
                  //       icon: const Icon(Icons.skip_next),
                  //       onPressed: _isPlayerReady
                  //           ? () => _controller.load(_ids[
                  //               (_ids.indexOf(_controller.metadata.videoId) +
                  //                       1) %
                  //                   _ids.length])
                  //           : null,
                  //     ),
                  //   ],
                  // ),
                  // _space,

                  _space,
                  // AnimatedContainer(
                  //   duration: const Duration(milliseconds: 800),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(20.0),
                  //     color: _getStateColor(_playerState),
                  //   ),
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(
                  //     _playerState.toString(),
                  //     style: const TextStyle(
                  //       fontWeight: FontWeight.w300,
                  //       color: Colors.white,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  Row(
                    children: [
                      _text('Title', _videoMetaData.title),
                      const Spacer(),
                      _text('Channel', _videoMetaData.author),
                    ],
                  ),
                  _space,
                  Row(
                    children: [
                      _text('Video Id', _videoMetaData.videoId),
                      const Spacer(),
                      _text(
                        'Playback Rate',
                        '${_controller.value.playbackRate}x  ',
                      ),
                    ],
                  ),
                  _space,
                  Row(
                    children: [
                      _text(
                          'Duration', "${_videoMetaData.duration.inSeconds} s"),
                      const Spacer(),
                      _text('Time Passed',
                          "${_controller.value.position.inSeconds} s"),
                      const Spacer(),
                      _text(
                        'PlayerStatus',
                        '${_controller.value.playerState.name}',
                      ),
                    ],
                  ),
                  _space,
                  // Row(
                  //   children: [
                  //     _text('Time Passed',
                  //         "${_controller.value.position.inSeconds} seconds"),
                  //     const Spacer(),
                  //     // _text(
                  //     //   'Volume',
                  //     //   '${_controller.value.volume}',
                  //     // ),
                  //   ],
                  // ),
                  Row(
                    children: <Widget>[
                      const Text(
                        "Volume",
                        style: TextStyle(
                            color: Colors.purple, fontWeight: FontWeight.w300),
                      ),
                      Expanded(
                        child: Slider(
                          inactiveColor: Colors.transparent,
                          value: _volume,
                          min: 0.0,
                          max: 100.0,
                          divisions: 10,
                          label: '${(_volume).round()}',
                          thumbColor: Colors.purple.withOpacity(1),
                          activeColor: Colors.purple.withOpacity(0.5),
                          onChanged: _isPlayerReady
                              ? (value) {
                                  setState(() {
                                    _volume = value;
                                  });
                                  _controller.setVolume(_volume.round());
                                }
                              : null,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _muted
                              ? Icons.volume_off_outlined
                              : Icons.volume_up_outlined,
                          color: Colors.purple,
                        ),
                        onPressed: _isPlayerReady
                            ? () {
                                _muted
                                    ? _controller.unMute()
                                    : _controller.mute();
                                setState(() {
                                  _muted = !_muted;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  _space,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.purple.withOpacity(0.6),
        onPressed: _isPlayerReady
            ? () {
                if (_idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        _idController.text,
                      ) ??
                      '';
                  if (action == 'Search') {
                    _controller.load(id);
                    isVisible = false;
                  }

                  if (action == 'CUE') _controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
