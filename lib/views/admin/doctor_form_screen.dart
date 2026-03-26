import 'package:doctor_appointment_app/implementations/repository/doctor_repository.dart';
import 'package:doctor_appointment_app/views/home/models/doctor_item.dart';
import 'package:flutter/material.dart';

class DoctorFormScreen extends StatefulWidget {
  const DoctorFormScreen({super.key, this.initialDoctor});

  final DoctorItem? initialDoctor;

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DoctorRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _specialtyController;
  late final TextEditingController _hospitalController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewCountController;
  late final TextEditingController _imagePathController;

  bool _isFavorite = false;
  bool _isSaving = false;

  bool get _isEdit => widget.initialDoctor != null;

  @override
  void initState() {
    super.initState();
    final doctor = widget.initialDoctor;
    _nameController = TextEditingController(text: doctor?.name ?? '');
    _specialtyController = TextEditingController(text: doctor?.specialty ?? '');
    _hospitalController = TextEditingController(text: doctor?.hospitalName ?? '');
    _ratingController = TextEditingController(text: (doctor?.rating ?? 0).toString());
    _reviewCountController =
        TextEditingController(text: (doctor?.reviewCount ?? 0).toString());
    _imagePathController = TextEditingController(
      text: doctor?.imageAssetPath ?? 'assets/images/doctor.png',
    );
    _isFavorite = doctor?.isFavorite ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _hospitalController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final doctor = DoctorItem(
      id: widget.initialDoctor?.id ??
          'd_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      specialty: _specialtyController.text.trim(),
      hospitalName: _hospitalController.text.trim(),
      rating: double.parse(_ratingController.text.trim()),
      reviewCount: int.parse(_reviewCountController.text.trim()),
      imageAssetPath: _imagePathController.text.trim(),
      isFavorite: _isFavorite,
    );

    try {
      final ok =
          _isEdit ? await _repository.updateDoctor(doctor) : await _repository.addDoctor(doctor);
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu bác sĩ')),
        );
        setState(() => _isSaving = false);
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu thất bại: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Doctor' : 'Add Doctor')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Name'),
            const SizedBox(height: 12),
            _buildTextField(_specialtyController, 'Specialty'),
            const SizedBox(height: 12),
            _buildTextField(_hospitalController, 'Hospital Name'),
            const SizedBox(height: 12),
            _buildTextField(
              _ratingController,
              'Rating (0-5)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập rating';
                }
                final rating = double.tryParse(value.trim());
                if (rating == null || rating < 0 || rating > 5) {
                  return 'Rating phải trong khoảng 0 - 5';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _reviewCountController,
              'Review Count',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số lượt đánh giá';
                }
                final count = int.tryParse(value.trim());
                if (count == null || count < 0) {
                  return 'Giá trị không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(_imagePathController, 'Image Asset Path'),
            SwitchListTile(
              value: _isFavorite,
              onChanged: (v) => setState(() => _isFavorite = v),
              title: const Text('Is Favorite'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập $label';
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

