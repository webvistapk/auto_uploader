import 'package:flutter/material.dart';

class OwnMessage extends StatelessWidget {
  final String text;
  final String timestamp;

  const OwnMessage({
    Key? key,
    required this.text,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Timestamp
          Text(
            timestamp,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Message Bubble
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(left: 55, right: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 103, 207, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'sent',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
