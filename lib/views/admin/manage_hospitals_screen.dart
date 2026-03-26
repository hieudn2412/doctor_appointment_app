import 'package:doctor_appointment_app/implementations/repository/hospital_repository.dart';
import 'package:doctor_appointment_app/views/admin/hospital_form_screen.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:flutter/material.dart';

class ManageHospitalsScreen extends StatefulWidget {
  const ManageHospitalsScreen({super.key});

  @override
  State<ManageHospitalsScreen> createState() => _ManageHospitalsScreenState();
}

class _ManageHospitalsScreenState extends State<ManageHospitalsScreen> {
  final HospitalRepository _repository = HospitalRepository();

  bool _isLoading = true;
  String? _error;
  List<HospitalItem> _hospitals = const [];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hospitals = await _repository.getAllHospitals();
      if (!mounted) return;
      setState(() {
        _hospitals = hospitals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải danh sách bệnh viện: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm({HospitalItem? hospital}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => HospitalFormScreen(initialHospital: hospital),
      ),
    );

    if (changed == true) {
      await _loadHospitals();
    }
  }

  Future<void> _deleteHospital(HospitalItem hospital) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc muốn xóa bệnh viện "${hospital.name}" không?'),
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
      final ok = await _repository.deleteHospital(hospital.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'Đã xóa bệnh viện' : 'Không thể xóa bệnh viện')),
      );
      await _loadHospitals();
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
      appBar: AppBar(title: const Text('Manage Hospitals')),
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

    if (_hospitals.isEmpty) {
      return const Center(child: Text('Chưa có bệnh viện nào'));
    }

    return RefreshIndicator(
      onRefresh: _loadHospitals,
      child: ListView.separated(
        itemCount: _hospitals.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final hospital = _hospitals[index];
          return ListTile(
            title: Text(hospital.name),
            subtitle: Text(hospital.address),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _openForm(hospital: hospital),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _deleteHospital(hospital),
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
