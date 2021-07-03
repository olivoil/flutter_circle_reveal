import 'dart:math';
import 'dart:ui' as ui;

import 'package:circle_reveal_transition/onboarding_pages.dart' as onboarding;
import 'package:circle_reveal_transition/widget_workshop_scaffold.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetWorkshop(),
    );
  }
}

class WidgetWorkshop extends StatefulWidget {
  const WidgetWorkshop({Key? key}) : super(key: key);

  @override
  _WidgetWorkshopState createState() => _WidgetWorkshopState();
}

class _WidgetWorkshopState extends State<WidgetWorkshop>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double _transitionPercent;

  late int _currentPageIndex;
  late onboarding.Page _currentPage;
  late onboarding.Page _secondPage;
  late onboarding.Page _thirdPage;
  late onboarding.Page _visiblePage;

  @override
  void initState() {
    super.initState();

    _currentPageIndex = 0;
    _currentPage = onboarding.pages[0];
    _secondPage = onboarding.pages[1];
    _thirdPage = onboarding.pages[2];
    _visiblePage = _currentPage;

    _transitionPercent = 0;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )
      ..addListener(() {
        setState(() {
          _transitionPercent = _animationController.value;

          if (_transitionPercent < 0.5) {
            _visiblePage = _currentPage;
          } else {
            _visiblePage = _secondPage;
          }
        });
      })
      ..addStatusListener((status) {
        setState(() {
          if (AnimationStatus.completed == status) {
            int len = onboarding.pages.length;

            _currentPageIndex = (_currentPageIndex + 1) % len;
            _currentPage = onboarding.pages[_currentPageIndex];
            _visiblePage = _currentPage;
            _secondPage = onboarding.pages[(_currentPageIndex + 1) % len];
            _thirdPage = onboarding.pages[(_currentPageIndex + 2) % len];

            _animationController.value = 0;
            _transitionPercent = 0;
          }
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the position of the onboarding content
    final double maxOffset = 300;
    double offsetPercent = 1;

    if (_transitionPercent <= 0.25) {
      offsetPercent = -_transitionPercent / 0.25;
    } else if (_transitionPercent >= 0.7) {
      offsetPercent = (1.0 - _transitionPercent) / 0.3;
      offsetPercent = Curves.easeInCubic.transform(offsetPercent);
    }

    final double contentOffset = offsetPercent * maxOffset;
    final double contentScale = 0.6 + (0.4 * (1.0 - offsetPercent.abs()));

    return CustomPaint(
      painter: CircleTransitionPainter(
        backgroundColor: _currentPage.backgroundColor,
        currentCircleColor: _secondPage.backgroundColor,
        nextCircleColor: _thirdPage.backgroundColor,
        transitionPercent: _transitionPercent,
      ),
      child: WidgetWorkshopScaffold(
        showTransitionPlayer: false,
        animationController: _animationController,
        backgroundBrightness: _visiblePage.backgroundBrightness,
        title: _visiblePage.title,
        child: Transform(
          transform: Matrix4.translationValues(contentOffset, 0, 0)
            ..scale(contentScale, contentScale),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 20),
              Container(
                width: 250,
                height: 200,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      _visiblePage.imageAssetPath,
                      fit: BoxFit.cover,
                      alignment: _visiblePage.imageAlignment,
                    )),
              ),
              Spacer(flex: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  _visiblePage.description,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: _visiblePage.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(flex: 10),
              GestureDetector(
                onTap: () {
                  _animationController.forward();
                },
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.red.withOpacity(0),
                ),
              ),
              Spacer(flex: 70),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleTransitionPainter extends CustomPainter {
  CircleTransitionPainter({
    required Color backgroundColor,
    required Color currentCircleColor,
    required Color nextCircleColor,
    this.transitionPercent = 0,
  })  : backgroundPaint = Paint()..color = backgroundColor,
        currentCirclePaint = Paint()..color = currentCircleColor,
        nextCirclePaint = Paint()..color = nextCircleColor;

  final double baseCircleRadius = 36;
  final Paint backgroundPaint;
  final Paint currentCirclePaint;
  final Paint nextCirclePaint;
  final double transitionPercent;

  @override
  void paint(Canvas canvas, Size size) {
    if (transitionPercent < 0.5) {
      final double expansionPercent = transitionPercent / 0.5;
      _paintExpansion(canvas, size, expansionPercent);
    } else {
      final double contractionPercent = (transitionPercent - 0.5) / 0.5;
      _paintContraction(canvas, size, contractionPercent);
    }
  }

  void _paintExpansion(Canvas canvas, Size size, double expansionPercent) {
    // The max radius that the circle will grow to
    final double maxRadius = size.height * 200;

    // The original center position of the circle
    Offset baseCircleCenter = Offset(size.width / 2, size.height * 0.76);

    // The left side of the circle, which never moves during expansion
    final double circleLeftBound = baseCircleCenter.dx - baseCircleRadius;

    // Apply exponential reduction to the expansion rate so that the circle
    // expands much, much slower.
    final double slowedExpansionPercent = pow(expansionPercent, 10).toDouble();

    final double currentRadius =
        (maxRadius * slowedExpansionPercent) + baseCircleRadius;

    final Offset currentCircleCenter = Offset(
      circleLeftBound + currentRadius,
      baseCircleCenter.dy,
    );

    // Paint background
    canvas.drawPaint(backgroundPaint);

    // Paint circle
    canvas.drawCircle(currentCircleCenter, currentRadius, currentCirclePaint);

    if (expansionPercent < 0.1) {
      _paintChevron(canvas, baseCircleCenter, backgroundPaint.color);
    }
  }

  void _paintContraction(Canvas canvas, Size size, double contractionPercent) {
    // The max radius that the circle will start at
    final double maxRadius = size.height * 200;

    // The original center position of the circle
    Offset baseCircleCenter = Offset(size.width / 2, size.height * 0.76);

    // The right side of the circle at the start of the animation, which becomes
    // the left side of the circle by the end of the animation.
    final double circleStartingRightSide =
        baseCircleCenter.dx - baseCircleRadius;

    // The final right side of the circle.
    final double circleFinalRightSide = baseCircleCenter.dx + baseCircleRadius;

    // Apply exponential reduction to the contraction rate so that the circle
    // contracts much, much slower.
    final double easedContractionPercent =
        Curves.easeInOut.transform(contractionPercent);
    final double inverseContractionPercent = 1 - contractionPercent;
    final double slowedInversedContractionPercent =
        pow(inverseContractionPercent, 10).toDouble();

    final double currentRadius =
        (maxRadius * slowedInversedContractionPercent) + baseCircleRadius;

    final double circleCurrentRightSide = circleStartingRightSide +
        ((circleFinalRightSide - circleStartingRightSide) *
            easedContractionPercent);

    final Offset currentCircleCenter = Offset(
      circleCurrentRightSide - currentRadius,
      baseCircleCenter.dy,
    );

    // Paint background
    canvas.drawPaint(currentCirclePaint);

    // Paint circle
    canvas.drawCircle(currentCircleCenter, currentRadius, backgroundPaint);

    // Paint the new expanding circle.
    if (contractionPercent > 0.9) {
      double newCircleExpansionPercent =
          pow((easedContractionPercent - 0.9) / 0.1, 4).toDouble();
      double newCircleRadius = baseCircleRadius * newCircleExpansionPercent;
      canvas.drawCircle(currentCircleCenter, newCircleRadius, nextCirclePaint);
      _paintChevron(canvas, currentCircleCenter, currentCirclePaint.color);
    }
  }

  void _paintChevron(Canvas canvas, Offset circleCenter, Color color) {
    final IconData chevronIcon = Icons.arrow_forward_ios_outlined;

    final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        fontFamily: chevronIcon.fontFamily,
        fontSize: 18,
        textAlign: TextAlign.center,
      ),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(String.fromCharCode(chevronIcon.codePoint));

    final ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: baseCircleRadius));

    canvas.drawParagraph(paragraph,
        circleCenter - Offset(paragraph.width / 2, paragraph.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
