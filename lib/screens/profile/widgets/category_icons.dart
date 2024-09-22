import 'package:flutter/material.dart';

class CategoryIcons extends StatelessWidget {
  final List<String> images;
  const CategoryIcons({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(images.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(images[index]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category ${index + 1}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
