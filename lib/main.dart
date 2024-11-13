import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_5/firebase_options.dart';
import 'login_screen.dart';
import 'tasklist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class TaskItem extends StatelessWidget {
  final QueryDocumentSnapshot task;

  TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task['name']),
      leading: Checkbox(
        value: task['completed'],
        onChanged: (bool? value) {
          task.reference.update({'completed': value});
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => task.reference.delete(),
      ),
      onTap: () => _showSubtasks(context),
    );
  }

  void _showSubtasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subtasks for ${task['name']}"),
          content: StreamBuilder(
            stream: task.reference.collection('subtasks').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              return ListView(
                children: snapshot.data!.docs.map((subtask) {
                  return ListTile(
                    title: Text(subtask['description']),
                    subtitle: Text(subtask['time']),
                    trailing: Checkbox(
                      value: subtask['completed'],
                      onChanged: (bool? value) {
                        subtask.reference.update({'completed': value});
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthGate(), 
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return TaskListScreen(); 
        }
        return LoginScreen(); 
      },
    );
  }
}

