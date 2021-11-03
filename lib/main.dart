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
  /// for animation from small to large radius
  late final AnimationController _buttonForwardAnimationController;
  /// for animation from large radius to [_buttonHeight]
  late final AnimationController _buttonReverseAnimationController;
  /// Used for animating overlay button on top of the button(the radius animating button) 
  /// that actually getting animated. This animation helps to give a scale transition at the 
  /// end of the revserse animation.
  late final AnimationController _buttonSizeAnimationController;

  late final Animation _buttonAnimationForward;
  late final Animation _buttonAnimationReverse;
  late final Animation _buttonSizeAnimation;

  /// as the button's radius increases its distance from the left 
  /// is fixed till it reaces the end, where the button flats out. Now
  /// [_fromLeft] should have a transition to [_fromRight] such that 
  /// button ends up in the center.
  late double? _fromLeft;
  late double? _fromRight;

  late Function(AnimationStatus) _forwardListener;
  late Function(AnimationStatus) _reverseListener;
  late Function(AnimationStatus) _buttonStatusListener;

  /// initial background color and button color with the colors array.
  Color _backgroundColor = Color(0xffffbfdf);
  Color _buttonColor = Color(0xff0145D0);
  bool _isAnimatingReverse = false;
  bool _isAnimating = false;

  final List<Color> _colors = [
    Color(0xffffbfdf),
    Color(0xff0145D0),
    Colors.white,
  ];

  /// color index changes when the animation completes and updating the UI.
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
        /// giving a custom curve that starts very slow and at the end accelerate
        /// quickly.
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
              setState(() {
                if (_buttonReverseAnimationController.value > 0.9 &&
                    !_buttonSizeAnimationController.isAnimating) {
                      /// The scale animation at the end where overlay
                      /// button pops out of the center of the below button
                      /// will initiate only after reverse animation completed 90%
                  _buttonSizeAnimationController.forward();
                }
              });
            },
          );
    _buttonSizeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _buttonSizeAnimation = Tween<double>(begin: 0, end: _buttonHeight).animate(
      CurvedAnimation(
        parent: _buttonSizeAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    )..addListener(() {
        setState(() {});
      });

    _forwardListener = (status) {
      if (status == AnimationStatus.completed) {
        /// When forward animation completed we
        /// set the background color to button color
        /// setting button color to background color 
        /// starting reverse animation
        /// setting [_isAnimatingReverse] to true which handles [_fromRight] value
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
          _isAnimating = false;
          _buttonForwardAnimationController.reset();
          _buttonReverseAnimationController.reset();
          _colorIndex++;
          _buttonReverseAnimationController
              .removeStatusListener(_reverseListener);
        });
      }
    };

    _buttonStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _buttonColor = _colors[(_colorIndex + 1) % _colors.length];
          _buttonSizeAnimationController
              .removeStatusListener(_buttonStatusListener);
          _buttonSizeAnimationController.reset();
        });
      }
    };
  }

  @override
  void dispose() {
    _buttonForwardAnimationController.dispose();
    _buttonReverseAnimationController.dispose();
    _buttonSizeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// [_fromLeft] is the exact horizontal 
    /// center of the screen, means the center of the button is 
    /// at the horizontal center of the screen. That means the left border
    /// at [MediaQuery.of(context).size.width / 2 + _buttonHeight / 2] from right
    _fromLeft = MediaQuery.of(context).size.width / 2 - _buttonHeight / 2;
    /// [_fromRight] changes dynamically when [_buttonReverseAnimationController] reaches
    /// half to make the animation look smooth. It make a linear transition from
    /// (W/2 + w/2) -> (W/2 - w/2)
    /// W = screen width
    /// w = button width 
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
                  if (_isAnimating ||
                      _buttonSizeAnimationController.isAnimating) return;
                  _buttonForwardAnimationController.forward();
                  _isAnimating = true;
                  _buttonForwardAnimationController
                      .addStatusListener(_forwardListener);
                  _buttonReverseAnimationController
                      .addStatusListener(_reverseListener);
                  _buttonSizeAnimationController
                      .addStatusListener(_buttonStatusListener);
                },
                child: Column(
                  children: [
                    const SizedBox(height: 350),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        /// The scaling button 
                        Container(
                          height: _buttonReverseAnimationController
                                      .isAnimating ||
                                  _buttonForwardAnimationController.isCompleted
                              ? _buttonAnimationReverse.value
                              : _buttonAnimationForward.value,
                          width: _buttonReverseAnimationController
                                      .isAnimating ||
                                  _buttonForwardAnimationController.isCompleted
                              ? _buttonAnimationReverse.value
                              : _buttonAnimationForward.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _buttonColor,
                          ),
                        ),
                        /// The overlay button
                        if (!_isAnimating)
                          Container(
                            height: _buttonSizeAnimationController.isAnimating
                                ? _buttonSizeAnimation.value
                                : _buttonHeight,
                            width: _buttonSizeAnimationController.isAnimating
                                ? _buttonSizeAnimation.value
                                : _buttonHeight,
                            decoration: BoxDecoration(
                              color:
                                  _colors[(_colorIndex + 1) % _colors.length],
                              borderRadius:
                                  BorderRadius.circular(_buttonHeight),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: _backgroundColor,
                                size: _buttonSizeAnimationController.isAnimating
                                    ? _buttonSizeAnimation.value / 4
                                    : _buttonHeight / 4,
                              ),
                            ),
                          ),
                      ],
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
