import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // timeDilation = 7;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with TickerProviderStateMixin {
  final double _buttonHeight = 100;
  late final AnimationController _buttonForwardAnimationController;
  late final AnimationController _buttonReverseAnimationController;

  late final Animation _buttonAnimationForward;
  late final Animation _buttonAnimationReverse;

  late double? _fromLeft;
  late double? _fromRight;

  late Function(AnimationStatus) _forwardListener;
  late Function(AnimationStatus) _reverseListener;
  Color _backgroundColor = Colors.white;
  Color _buttonColor = Colors.redAccent;
  bool _isAnimatingReverse = false;

  final List<Color> _colors = [
    Color(0xffffbfdf),
    Color(0xff0145D0),
    Colors.white
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _buttonForwardAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _buttonReverseAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _buttonAnimationForward =
        Tween<double>(begin: _buttonHeight, end: 40000).animate(
      CurvedAnimation(
        parent: _buttonForwardAnimationController,
        curve: Cubic(1, 0, 1, 0),
      ),
    )..addListener(
            () {
              setState(() {});
            },
          );
    _buttonAnimationReverse =
        Tween<double>(begin: 40000, end: _buttonHeight).animate(
      CurvedAnimation(
        parent: _buttonReverseAnimationController,
        curve: Cubic(0, 1, 0, 1),
      ),
    )..addListener(
            () {
              setState(() {});
            },
          );

    _forwardListener = (status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _backgroundColor = _buttonColor;
          _buttonColor = _colors[(_colorIndex) % _colors.length];
          _buttonReverseAnimationController.forward();
          _isAnimatingReverse = true;
          _buttonForwardAnimationController
              .removeStatusListener(_forwardListener);
        });
      }
    };

    _reverseListener = (status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimatingReverse = false;
          _buttonForwardAnimationController.reset();
          _buttonReverseAnimationController.reset();
          _colorIndex++;
          _buttonColor = _colors[(_colorIndex + 1) % _colors.length];
          _buttonReverseAnimationController
              .removeStatusListener(_reverseListener);
        });
      }
    };
  }

  @override
  void dispose() {
    _buttonForwardAnimationController.dispose();
    _buttonReverseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _fromLeft = MediaQuery.of(context).size.width / 2 - _buttonHeight / 2;
    _fromRight = _buttonReverseAnimationController.value >= 0.5
        ? MediaQuery.of(context).size.width / 2 -
            2 * _buttonHeight * _buttonReverseAnimationController.value +
            (3 * _buttonHeight) / 2
        : MediaQuery.of(context).size.width / 2 + _buttonHeight / 2;
    return Scaffold(
      body: Container(
        color: _backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: _isAnimatingReverse ? _fromRight : null,
              left: !(_isAnimatingReverse) ? _fromLeft : null,
              child: GestureDetector(
                onTap: () {
                  _buttonForwardAnimationController.forward();
                  _buttonForwardAnimationController
                      .addStatusListener(_forwardListener);
                  _buttonReverseAnimationController
                      .addStatusListener(_reverseListener);
                },
                child: Column(
                  children: [
                    const SizedBox(height: 350),
                    Container(
                      height: _buttonReverseAnimationController.isAnimating ||
                              _buttonForwardAnimationController.isCompleted
                          ? _buttonAnimationReverse.value
                          : _buttonAnimationForward.value,
                      width: _buttonReverseAnimationController.isAnimating ||
                              _buttonForwardAnimationController.isCompleted
                          ? _buttonAnimationReverse.value
                          : _buttonAnimationForward.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _buttonColor,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: _backgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Storief',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              top: 20,
            ),
            Positioned(
              top: 300,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Icon(Icons.add),
                    const SizedBox(height: 50),
                    Text('Add an alarm'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
