import 'package:circle_reveal_transition/onboarding_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetWorkshopScaffold extends StatelessWidget {
  const WidgetWorkshopScaffold({
    Key? key,
    required this.backgroundBrightness,
    required this.child,
    required this.animationController,
    required this.title,
    this.showTransitionPlayer = true,
  }) : super(key: key);

  final Brightness backgroundBrightness;
  final Widget child;
  final AnimationController animationController;
  final String title;
  final bool showTransitionPlayer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          child,
          TransitionPlayer(
            isVisible: showTransitionPlayer,
            animationController: animationController,
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(title, style: TextStyle(
        color: backgroundBrightness == Brightness.light ? Colors.black : Colors.white,
      )),
      brightness: backgroundBrightness,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

class TransitionPlayer extends StatelessWidget {
  const TransitionPlayer({Key? key, required this.isVisible, required this.animationController}) : super(key: key);

  final AnimationController animationController;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return isVisible ? Positioned(
      bottom: 25,
      left: 20,
      right: 20,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // widget.animationController.reset();
              animationController.forward(from: 0);
            },
            icon: animationController.isAnimating ? Icon(Icons.pause) : Icon(Icons.play_arrow),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.grey.shade900,
                inactiveTrackColor: Colors.grey.shade600,
                thumbColor: Colors.grey.shade900,
              ),
              child: Slider(
                // divisions: 150000,
                value: animationController.value,
                onChanged: (value) {
                  animationController.value = value;
                },
              ),
            ),
          ),
        ],
      ),
    ) : Center();
  }
}

