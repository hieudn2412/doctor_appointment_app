import 'package:doctor_appointment_app/implementations/repository/doctor_repository.dart';
import 'package:doctor_appointment_app/views/admin/doctor_form_screen.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter/material.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  final DoctorRepository _repository = DoctorRepository();

  bool _isLoading = true;
  String? _error;
  List<DoctorItem> _doctors = const [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doctors = await _repository.getAllDoctors();
      if (!mounted) return;
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải danh sách bác sĩ: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm({DoctorItem? doctor}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DoctorFormScreen(initialDoctor: doctor),
      ),
    );

    if (changed == true) {
      await _loadDoctors();
    }
  }

  Future<void> _deleteDoctor(DoctorItem doctor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa bác sĩ "${doctor.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final ok = await _repository.deleteDoctor(doctor.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Đã xóa bác sĩ' : 'Không thể xóa bác sĩ')),
      );
      await _loadDoctors();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xóa thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctors')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_doctors.isEmpty) {
      return const Center(child: Text('Chưa có bác sĩ nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadDoctors,
      child: ListView.separated(
        itemCount: _doctors.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final doctor = _doctors[index];
          return ListTile(
            title: Text(doctor.name),
            subtitle: Text('${doctor.specialty} • ${doctor.hospitalName}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _openForm(doctor: doctor),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _deleteDoctor(doctor),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
