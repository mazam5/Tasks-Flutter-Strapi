import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class StrapiService {
  static const String baseUrl = 'http://10.0.2.2:1337';
  List<Map<String, dynamic>> strapiTasks = [];

  // Fetch todos
  Future<List> fetchTasks() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/tasks'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> tasksData = responseData['data'];
        final List<Map<String, dynamic>> tasks = tasksData
            .map((task) => {
                  'id': task['id'],
                  ...task['attributes'] as Map<String, dynamic>
                })
            .toList();
        strapiTasks = tasks;
        return tasks;
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  Future<void> addTask(Map<String, dynamic> todo) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/api/tasks'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                "data": {
                  "title": todo['title'],
                  "description": todo['description'],
                  "completed": todo['completed'],
                }
              }))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchTasks();
      } else {
        throw Exception('Failed to add todo');
      }
    } catch (e) {
      print('Error adding todo: $e');
      throw e;
    }
  }

  Future<void> markTask(Map<String, dynamic> todo) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/api/tasks/${todo['id']}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              "data": {
                "title": todo['title'],
                "description": todo['description'],
                "completed": !todo['completed'],
              }
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        throw Exception('Failed to update todo');
      }
    } catch (e) {
      print('Error updating todo: $e');
      throw e;
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/api/tasks/$id'), headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        await fetchTasks();
      } else {
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }

  void logout() {}
}
