import 'package:flutter/material.dart';
import '../models/landmine_detection.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final List<LandmineDetection> detections;

  const HistoryPage({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmine Detection History'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detection History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                color: Colors.black87,
                child: detections.isEmpty
                    ? const Center(
                        child: Text(
                          'No detections yet',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: detections.length,
                        itemBuilder: (context, index) {
                          final detection = detections[index];
                          return Card(
                            color: Colors.black54,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.red,
                                child: Icon(Icons.warning,
                                    color: Colors.white, size: 20),
                              ),
                              title: Text(
                                'Landmine Detected',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Coordinates: (${detection.latitude.toStringAsFixed(6)}, ${detection.longitude.toStringAsFixed(6)})\nDetected on: ${DateFormat('MMM d, y HH:mm').format(detection.timestamp)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
