import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.deepPurple.shade100,
      highlightColor: Colors.deepPurple.shade300,
      period: Duration(seconds: 2), // Slower shimmer for a smoother effect
      child: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (_, __) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 10.0, // Smooth shadow effect
                  spreadRadius: 2.0,
                  offset: Offset(3.0, 3.0),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              ),
            ),
            height: 300.0,
          );
        },
        itemCount: 6,
      ),
    );
  }
}
