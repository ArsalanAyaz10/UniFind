import 'package:flutter/material.dart';

class LostFoundItemCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final String campus;
  final String specificLocation;
  final String category; // 'Lost' or 'Found'
  final String date;
  final String time;
  final VoidCallback? onTap;

  const LostFoundItemCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.campus,
    required this.specificLocation,
    required this.category,
    required this.date,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 60)),
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location & Campus
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text('$campus - $specificLocation',
                            style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Date, Time, and Category Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$date | $time',
                          style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: category == 'Lost'
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: category == 'Lost'
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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
