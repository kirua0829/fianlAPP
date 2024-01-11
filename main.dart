import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primaryColor: Colors.pinkAccent),
    home: HomeScreen(),
  ));
}

class ScoreScreen extends StatefulWidget {
  final int gameDuration;

  ScoreScreen({required this.gameDuration});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int score = 0;
  double topPosition = 0;
  double leftPosition = 0;
  int seconds = 0;
  int highScore = 0;
  late Timer _timer;
  bool isGameActive = false;
  bool startButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 0), () {});
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _updateScoreAndPosition() {
    if (isGameActive && seconds < widget.gameDuration) {
      setState(() {
        _changeButtonPosition();
        if (isGameActive) {
          score += 10;
        }

        if (seconds >= widget.gameDuration) {
          _endGame();
        }
      });
    }
  }

  void _changeButtonPosition() {
    final random = Random();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    topPosition = (random.nextDouble() * screenHeight) + screenHeight * 0.1;
    leftPosition = random.nextDouble() * (screenWidth - 56);

    while (topPosition + 56 > screenHeight * 0.6 || topPosition < screenHeight * 0.1) {
      topPosition = (random.nextDouble() * screenHeight);
    }
    if (leftPosition + 56 > screenWidth - 56) {
      leftPosition = screenWidth - 56 * 2;
    }
  }

  void _resetScore() {
    setState(() {
      if (isGameActive) {
        _endGame();
        isGameActive = false;
      }
      score = 0;
      seconds = 0;
      _changeButtonPosition();
      if (_timer.isActive) {
        _timer.cancel();
      }
      startButtonVisible = true;
    });
  }

  void _startGame() {
    setState(() {
      _resetScore();
      _changeButtonPosition();
      _startTimer();
      isGameActive = true;
      startButtonVisible = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isGameActive) {
        timer.cancel();
      } else {
        setState(() {
          seconds += 1;
          if (seconds >= widget.gameDuration) {
            _endGame();
          }
        });
      }
    });
  }

  void _endGame() {
    if (_timer.isActive) {
      _timer.cancel();
      if (score > highScore) {
        highScore = score;
      }
    }
    isGameActive = false;
    startButtonVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.gameDuration}秒模式'),
        backgroundColor: Colors.pinkAccent,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text(
              '回到主畫面',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '分數: $score',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetScore,
                  child: Text('重置'),
                ),
              ],
            ),
          ),
          Positioned(
            top: topPosition,
            left: leftPosition,
            child: ElevatedButton(
              onPressed: isGameActive ? _updateScoreAndPosition : null,
              child: Text('按我加分'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(30),
                shape: CircleBorder(),
                primary: Colors.green,
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              '遊戲時間: $seconds 秒',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              '最高分數: $highScore',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: startButtonVisible ? _startGame : null,
              child: Text('開始'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _customDurationController;

  @override
  void initState() {
    super.initState();
    _customDurationController = TextEditingController();
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  void _startCustomGame() {
    if (_customDurationController.text.isNotEmpty &&
        int.tryParse(_customDurationController.text) != null) {
      int customDuration = int.parse(_customDurationController.text);
      if (customDuration > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreScreen(gameDuration: customDuration),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('請輸入有效的正整數。'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('汝阿茲海默否?(請填入正整數)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主畫面'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScoreScreen(gameDuration: 60),  // 更改為 60 秒
                  ),
                );
              },
              child: Text('60秒模式'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
              ),

            ),
            SizedBox(height: 250),  // 新增的 SizedBox(250)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _customDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '自定義秒數'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _startCustomGame,
                  child: Text('開始'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
