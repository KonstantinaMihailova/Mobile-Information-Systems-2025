import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lab1/widgets/exam_grid.dart';

import '../models/exam.dart';

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Exam> _exam;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExamList();
  }

  @override
  Widget build(BuildContext context) {
    final total = _isLoading ? 0 : _exam.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(12),
        child: ExamGrid(exam: _exam),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Вкупно испити:', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Chip(
              label: Text('$total', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.black26,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            )
          ],
        ),
      ),
    );
  }

  void _loadExamList() async{
    List<Exam> examsList = [];
    examsList.add(Exam(id:17, name: 'Калкулус', dateTime: DateTime.parse('2025-09-25T10:30:00'), classrooms: ['Просторија 110', 'АМФ ФИНКИ М']));
    examsList.add(Exam(id:18, name: 'Објектно програмирање', dateTime: DateTime.parse('2025-10-12T08:00:00'), classrooms: ['Просторија 220']));
    examsList.add(Exam(id:19, name: 'Информациска безбедност', dateTime: DateTime.parse('2025-08-18T14:30:00'), classrooms: ['АМФ ФИНКИ Г', 'Просторија 315']));
    examsList.add(Exam(id:20, name: 'Мобилна роботика', dateTime: DateTime.parse('2025-12-03T09:00:00'), classrooms: ['Просторија 210']));
    examsList.add(Exam(id:22, name: 'Веројатност и статистика', dateTime: DateTime.parse('2025-01-15T10:00:00'), classrooms: ['Просторија 116']));
    examsList.add(Exam(id:23, name: 'Напредно програмирање', dateTime: DateTime.parse('2026-02-10T09:00:00'), classrooms: ['Просторија 218']));
    examsList.add(Exam(id:24, name: 'Интернет на нештата', dateTime: DateTime.parse('2026-02-28T12:30:00'), classrooms: ['АМФ ФИНКИ М']));
    examsList.add(Exam(id:25, name: 'Компјутерски мрежи', dateTime: DateTime.parse('2026-03-25T10:30:00'), classrooms: ['Просторија 214']));
    examsList.add(Exam(id:26, name: 'Интернет програмирање', dateTime: DateTime.parse('2026-04-10T13:00:00'), classrooms: ['Просторија 301']));
    examsList.add(Exam(id:27, name: 'Дистрибуирани системи', dateTime: DateTime.parse('2026-04-25T09:30:00'), classrooms: ['АМФ МФ', 'Просторија 222']));
    examsList.add(Exam(id:28, name: 'Визуелизација', dateTime: DateTime.parse('2026-05-05T08:00:00'), classrooms: ['Просторија 317']));
    examsList.add(Exam(id:30, name: 'Дигитализација', dateTime: DateTime.parse('2026-06-03T09:00:00'), classrooms: ['Просторија 113']));
    examsList.add(Exam(id:32, name: 'Структурно програмирање', dateTime: DateTime.parse('2026-06-28T13:00:00'), classrooms: ['АМФ ФИНКИ М']));

    examsList.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    setState(() {
      _exam=examsList;
      _isLoading=false;
    });

  }
}