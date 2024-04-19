import 'package:flutter/material.dart';

class ImageScroll extends StatefulWidget {
  const ImageScroll({super.key});

  @override
  _ImageScrollState createState() => _ImageScrollState();
}

class _ImageScrollState extends State<ImageScroll> {
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.8,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.0,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          // Update the page controller based on the drag gesture
          _pageController.position
              .applyViewportDimension(details.primaryDelta! / 2);
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: 5,
          itemBuilder: (context, index) {
            return buildImage(index);
          },
        ),
      ),
    );
  }

  Widget buildImage(int index) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          getImagePath(index),
          width: 150.0,
          height: 200.0,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  String getImagePath(int index) {
    switch (index) {
      case 0:
        return 'assets/icons/ads4.jpg';
      case 1:
        return 'assets/icons/ads5.jpg';
      default:
        return 'assets/icons/ads6.jpg';
    }
  }
}
