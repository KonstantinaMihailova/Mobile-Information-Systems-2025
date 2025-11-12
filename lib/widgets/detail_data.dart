import 'package:flutter/material.dart';
import 'package:lab1/models/exam.dart';
import 'package:intl/intl.dart';

class DetailData extends StatelessWidget {
  final Exam exam;

  const DetailData({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isPast = exam.dateTime.isBefore(now);

    final Color borderColor =
    isPast ? Colors.blueGrey.shade600 : Colors.lightGreen.shade700;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Детали',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow('Име на предмет', exam.name, borderColor),
          _infoRow('Датум', DateFormat('dd.MM.yyyy').format(exam.dateTime), borderColor),
          _infoRow('Време', DateFormat('HH:mm').format(exam.dateTime), borderColor),
          _infoRow('Простории', exam.classrooms.join(', '), borderColor),
          _infoRow('Преостанато време', _formatRemaining(exam.dateTime), borderColor),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 18),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(DateTime examDateTime) {
    final now = DateTime.now();
    Duration diff = examDateTime.difference(now);

    final bool isPast = diff.isNegative;
    diff = diff.abs();

    final int days = diff.inDays;
    final int hours = diff.inHours - days * 24;

    final String formatted = '$days дена, $hours часа';
    return isPast ? 'Поминат: $formatted' : formatted;
  }
}
