import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../constants/app_theme.dart';

class AdminClassroomDetailScreen extends StatefulWidget {
  final String classroomId;
  final String classroomName;

  const AdminClassroomDetailScreen({
    super.key,
    required this.classroomId,
    required this.classroomName,
  });

  @override
  State<AdminClassroomDetailScreen> createState() => _AdminClassroomDetailScreenState();
}

class _AdminClassroomDetailScreenState extends State<AdminClassroomDetailScreen> {
  final FirestoreService _firestore = FirestoreService();

  Future<void> _showAddPostDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    File? selectedFile;
    String? fileType;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Classroom Post'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Topic / Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Content'),
                    ),
                    const SizedBox(height: 20),
                    if (selectedFile != null) ...[
                      Text('Selected: ${selectedFile!.path.split('/').last}'),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(type: FileType.image);
                            if (result != null && result.files.single.path != null) {
                                setState(() {
                                  selectedFile = File(result.files.single.path!);
                                  fileType = 'image';
                                });
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text('Poster'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                            if (result != null && result.files.single.path != null) {
                                setState(() {
                                  selectedFile = File(result.files.single.path!);
                                  fileType = 'pdf';
                                });
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;

                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Uploading post...')));

                    String? fileUrl;
                    if (selectedFile != null) {
                      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}';
                      fileUrl = await _firestore.uploadFile('classrooms/${widget.classroomId}/$fileName', selectedFile!);
                    }

                    await _firestore.addClassroomPost(
                      widget.classroomId,
                      titleController.text.trim(),
                      contentController.text.trim(),
                      fileUrl,
                      fileType,
                    );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Post added!')));
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open file')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isAdmin = authService.userRole == 'admin';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(widget.classroomName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.white)),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.getClassroomPostsStream(widget.classroomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No posts yet in this classroom.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;
              
              final fileUrl = data['fileUrl'] as String?;
              final fileType = data['fileType'] as String?;

              return Card(
                
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(data['title'] ?? 'No Title', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppTheme.primary),
                              onPressed: () => _firestore.deleteClassroomPost(widget.classroomId, id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(data['content'] ?? '', style: GoogleFonts.notoSansTamil(fontSize: 14)),
                      const SizedBox(height: 12),
                      if (fileUrl != null && fileType == 'image') ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(fileUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ],
                      if (fileUrl != null && fileType == 'pdf') ...[
                        ElevatedButton.icon(
                          onPressed: () => _launchUrl(fileUrl),
                          icon: const Icon(Icons.picture_as_pdf, color: AppTheme.white),
                          label: const Text('View PDF', style: TextStyle(color: AppTheme.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
        ? FloatingActionButton(
            backgroundColor: AppTheme.primary,
            onPressed: () => _showAddPostDialog(context),
            child: const Icon(Icons.add, color: AppTheme.white),
          )
        : null,
    );
  }
}
