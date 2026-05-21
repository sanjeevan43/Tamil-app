import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../constants/app_theme.dart';
import 'admin_classroom_detail_screen.dart';

class StudentClassroomsScreen extends StatelessWidget {
  const StudentClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Classrooms', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getClassroomsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No classrooms found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              return Card(
                
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school, color: AppTheme.primary),
                  ),
                  title: Text(data['name'] ?? '', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'] ?? '', style: GoogleFonts.notoSansTamil(fontSize: 14)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => AdminClassroomDetailScreen(
                        classroomId: id,
                        classroomName: data['name'] ?? 'Classroom',
                      ),
                    ));
                  },
                ),
              );
            },
          );
        }
      ),
    );
  }
}
