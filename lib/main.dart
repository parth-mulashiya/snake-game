// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {

  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final fontStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontFamily: 'Anta',
  );
  final randomGen = Random();

  var snake = [[0,1],[0,0]];
  var food = [0,2];
  var direction  = 'up';
  var isPlaying = false;

  void startGame(){
    const duration = Duration(milliseconds: 300);

    snake = [
      //snake head
      [(squaresPerRow / 2).floor(),(squaresPerCol/2).floor()]

    ];
    snake.add([snake.first[0],snake.first[1]-1]); // snake body

    createFood();
    isPlaying = true;
    Timer.periodic(duration, (timer) { 
      moveSnake();

      if(checkGameOver()){
        timer.cancel();
        endGame();
      }
    });
  }

  void createFood(){
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol)
    ];
  }

  void moveSnake(){
    setState(() {
      switch(direction){
        case 'up':
          snake.insert(0, [snake.first[0],snake.first[1]-1]);
          break;
        
        case 'down':
          snake.insert(0, [snake.first[0],snake.first[1]+1]);
          break;
        
        case 'left':
          snake.insert(0, [snake.first[0]-1,snake.first[1]]);
          break;

        case 'right':
          snake.insert(0, [snake.first[0]+1,snake.first[1]]);
          break;
      }

      if(snake.first[0] != food[0] || snake.first[1] != food[1]){
        snake.removeLast();
      }else{
        createFood();
      }
    });
  }

  bool checkGameOver(){
    if(
      !isPlaying
      || snake.first[1] < 0
      || snake.first[1] >= squaresPerCol
      || snake.first[0] < 0
      || snake.first[0] > squaresPerRow
    ){
      return true;
    }

    for(var i=1;i< snake.length;++i){
      if(snake[i][0] == snake.first[0] && snake[i][1] == snake.first[1]){
        return true;
      }
    }

    return false;
  }

  void endGame(){
    isPlaying = false;

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey.shade800,
        title: Text(
          "Game Over",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Anta',
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        content: Text(
          "Score : ${snake.length - 2}",
          style: TextStyle(fontSize: 20,fontFamily: 'Anta',color: Colors.white,),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Close",
              style: TextStyle(
                fontFamily: 'Anta',
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          )
        ],
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Text(
              "Snake Game",
              style: TextStyle(
                fontFamily: 'Codystar',
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if(direction != 'up' && details.delta.dy > 0){
                    direction = 'down';
                  }else if(direction != 'down' && details.delta.dy < 0){
                    direction = 'up';
                  }
                },
                onHorizontalDragUpdate: (details) {
                  if(direction != 'left' && details.delta.dx > 0){
                    direction = 'right';
                  }else if(direction != 'right' && details.delta.dx < 0){
                    direction = 'left';
                  }
                },
                child: AspectRatio(
                  aspectRatio: squaresPerRow / (squaresPerCol + 5 ),
                  child: GridView.builder(
                     physics: NeverScrollableScrollPhysics(),
                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: squaresPerRow,
                     ),
                     itemCount: squaresPerRow * squaresPerCol,
                     itemBuilder: (context, index) {
                       var color;
                       var x = index % squaresPerRow;
                       var y = (index / squaresPerRow).floor();
        
                      var isSnakeBody = false;
                      for(var pos in snake){
                        if(pos[0] == x && pos[1] == y){
                          isSnakeBody = true;
                          break;
                        }
                      }
        
                      if(snake.first[0] ==  x && snake.first[1] == y){
                        color = Colors.amber.shade600;
                      }else if(isSnakeBody){
                        color = Colors.amber.shade200;
                      }else if(food[0] == x && food[1] == y){
                        color = Colors.red;
                      }else{
                        color = Colors.grey.shade800;
                      }
        
                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: color == Colors.red ? Icon(Iconsax.emoji_happy_bold ,size: 12,color: Colors.black,): SizedBox(),
                      );
                     },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10,top: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color : isPlaying ? Colors.red : Colors.lightBlue,
                    child: Text(
                      isPlaying ? "End" : "Start",
                      style: fontStyle,
                    ),
                    onPressed: () {
                      if(isPlaying){
                        isPlaying = false;
                      }else{
                        startGame();
                      }
                      setState(() {
                        
                      });
                    },
                  ),
                  Text(
                    "Score : ${snake.length - 2}",
                    style: fontStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}