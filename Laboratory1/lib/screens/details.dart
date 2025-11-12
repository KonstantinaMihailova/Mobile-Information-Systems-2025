import 'package:flutter/material.dart';
import 'package:lab1/models/exam.dart';
import 'package:lab1/widgets/detail_data.dart';
import 'package:lab1/widgets/detail_title.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exam = ModalRoute.of(context)!.settings.arguments as Exam;

    final now = DateTime.now();
    final bool isPast = exam.dateTime.isBefore(now);

    final Color backgroundColor =
    isPast ? Colors.blueGrey.shade100 : Colors.lightGreen.shade100;
    final Color appBarColor =
    isPast ? Colors.blueGrey.shade700 : Colors.lightGreen.shade700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          exam.name.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            DetailTitle(id: exam.id, name: exam.name, isPast: isPast),
            const SizedBox(height: 30),
            DetailData(exam: exam),
          ],
        ),
      ),
    );
  }
}
