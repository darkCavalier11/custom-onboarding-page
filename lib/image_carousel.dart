import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

List<String> _subtitle = [
  'The never ending road',
  'A jungle safari',
  'Kingdom of magic',
];

final List<Color> _colors = [
  Color(0xffffbfdf),
  Color(0xff0145D0),
  Colors.white,
];

class ImageCarousel extends StatelessWidget {
  final CarouselController carouselController;
  const ImageCarousel({required this.carouselController, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [1, 2, 3]
          .map(
            (e) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 250,
                    width: 250,
                    child: Image.asset(
                      'assets/$e.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 250,
                  child: Text(
                    _subtitle[(e + 1) % 3],
                    style: TextStyle(
                      fontSize: 35,
                      color: _colors[(e) % 3],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 450,
        initialPage: 1,
        enlargeCenterPage: true,
        scrollPhysics: NeverScrollableScrollPhysics(),
      ),
      carouselController: carouselController,
    );
  }
}
