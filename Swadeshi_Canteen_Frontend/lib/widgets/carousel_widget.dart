import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarouselWidget extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final bool isLoading;

  const ImageCarouselWidget({
    Key? key,
    required this.imageUrls,
    required this.height,
    required this.isLoading,
  }) : super(key: key);

  @override
  _ImageCarouselWidgetState createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  int _currentIndex = 0; // To track the current index
  List<String> validImageUrls = [];

  @override
  void initState() {
    super.initState();
    _filterValidImageUrls();
  }

  // Filter valid image URLs initially
  void _filterValidImageUrls() {
    validImageUrls = widget.imageUrls.where((url) => url.isNotEmpty).toList();
  }

  // Remove an invalid image URL when an error occurs
  void _removeInvalidImageUrl(String url) {
    setState(() {
      validImageUrls.remove(url);
      if (_currentIndex >= validImageUrls.length) {
        _currentIndex = 0; // Reset index if it goes out of bounds
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display loading indicator if images are still loading
    if (widget.isLoading) {
      return Container(
        height: widget.height,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Hide the widget if there are no valid images after filtering
    if (validImageUrls.isEmpty) {
      return SizedBox.shrink();
    }

    // Carousel and indicator for valid images
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            // Pass vertical drag to parent scroll view
            Scrollable.of(context)?.position.moveTo(
              Scrollable.of(context)?.position.pixels ?? 0 - details.primaryDelta!,
              duration: Duration(milliseconds: 10),
              curve: Curves.linear,
            );
          },
        child: CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            autoPlay: true,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index; // Update current index on page change
              });
            },
          ),
          items: validImageUrls.map((item) {
            return GestureDetector(
              onTap: () {
                // Handle slide tap
                print('Tapped on slide: $item');
                // You can navigate or perform any action here
              },
              child: Container(
                child: Center(
                  child: Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: 1000,
                    // Error handling for invalid image URLs
                    errorBuilder: (context, error, stackTrace) {
                      // Remove the image if it fails to load
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   _removeInvalidImageUrl(item);
                      // });
                      return Container(color: Colors.grey[300],
                      child: Center(child: Icon(Icons.error, color: Colors.red)),
                      ); // Display empty container if the image fails
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        ),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: validImageUrls.asMap().entries.map((entry) {
            int index = entry.key;
            return GestureDetector(
              onTap: () {
                // Navigate to the tapped slide
                print('Tapped on dot: $index');
                // You can use the carousel controller to jump to the slide
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.blue : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
