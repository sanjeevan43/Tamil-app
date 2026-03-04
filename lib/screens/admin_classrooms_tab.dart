import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../constants/app_theme.dart';
import 'package:provider/provider.dart';
import 'admin_classroom_detail_screen.dart';

class AdminClassroomsTab extends StatefulWidget {
  const AdminClassroomsTab({super.key});

  @override
  State<AdminClassroomsTab> createState() => _AdminClassroomsTabState();
}

class _AdminClassroomsTabState extends State<AdminClassroomsTab> {
  final FirestoreService _firestore = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createClassroom() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.user?.uid ?? 'unknown_admin';

    await _firestore.createClassroom(
      _nameController.text.trim(),
      _descController.text.trim(),
      uid,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Classroom created!'), backgroundColor: Colors.green),
    );

    _nameController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Classrooms', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildCreationForm(),
          const SizedBox(height: 24),
          Expanded(child: _buildClassroomsList()),
        ],
      ),
    );
  }

  Widget _buildCreationForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Classroom Name (e.g., 8th Std Tamil Section A)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.topoLight,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: AppTheme.topoLight,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createClassroom,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppTheme.primary,
                ),
                child: Text('Create Classroom', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassroomsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getClassroomsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No classrooms found.'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final id = docs[index].id;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.school, color: Colors.white),
                ),
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['description'] ?? ''),
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
    );
  }
}
