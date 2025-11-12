import 'package:flutter/material.dart';
import 'package:lab1/models/exam.dart';
import 'package:intl/intl.dart';

class ExamCard extends StatelessWidget {
  final Exam exam;

  const ExamCard({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isPast = exam.dateTime.isBefore(now);

    final Color borderColor =
    isPast ? Colors.blueGrey.shade600 : Colors.lightGreen.shade700;

    final Color backgroundColor =
    isPast ? Colors.blueGrey.shade100 : Colors.lightGreen.shade100;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/details", arguments: exam);
      },
      child: Card(
        color: backgroundColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text(
                exam.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),
              Divider(color: borderColor, thickness: 1),
              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: borderColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(exam.dateTime),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: borderColor),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('HH:mm').format(exam.dateTime),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Divider(color: borderColor, thickness: 1),
              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room, size: 16, color: borderColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      exam.classrooms.join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
