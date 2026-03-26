import 'package:doctor_appointment_app/implementations/repository/hospital_repository.dart';
import 'package:doctor_appointment_app/views/home/models/hospital_item.dart';
import 'package:flutter/material.dart';

class HospitalFormScreen extends StatefulWidget {
  const HospitalFormScreen({super.key, this.initialHospital});

  final HospitalItem? initialHospital;

  @override
  State<HospitalFormScreen> createState() => _HospitalFormScreenState();
}

class _HospitalFormScreenState extends State<HospitalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = HospitalRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewCountController;
  late final TextEditingController _distanceController;
  late final TextEditingController _etaController;
  late final TextEditingController _typeController;
  late final TextEditingController _imagePathController;

  bool _isBookmarked = false;
  bool _isSaving = false;

  bool get _isEdit => widget.initialHospital != null;

  @override
  void initState() {
    super.initState();
    final hospital = widget.initialHospital;
    _nameController = TextEditingController(text: hospital?.name ?? '');
    _addressController = TextEditingController(text: hospital?.address ?? '');
    _ratingController =
        TextEditingController(text: (hospital?.rating ?? 0).toString());
    _reviewCountController =
        TextEditingController(text: (hospital?.reviewCount ?? 0).toString());
    _distanceController =
        TextEditingController(text: (hospital?.distanceKm ?? 0).toString());
    _etaController =
        TextEditingController(text: (hospital?.etaMinutes ?? 0).toString());
    _typeController = TextEditingController(text: hospital?.typeLabel ?? '');
    _imagePathController = TextEditingController(
      text: hospital?.imageAssetPath ?? 'assets/images/hospital_demo.jpg',
    );
    _isBookmarked = hospital?.isBookmarked ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    _distanceController.dispose();
    _etaController.dispose();
    _typeController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final hospital = HospitalItem(
      id: widget.initialHospital?.id ??
          'h_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      rating: double.parse(_ratingController.text.trim()),
      reviewCount: int.parse(_reviewCountController.text.trim()),
      distanceKm: double.parse(_distanceController.text.trim()),
      etaMinutes: int.parse(_etaController.text.trim()),
      typeLabel: _typeController.text.trim(),
      imageAssetPath: _imagePathController.text.trim(),
      isBookmarked: _isBookmarked,
    );

    try {
      final ok = _isEdit
          ? await _repository.updateHospital(hospital)
          : await _repository.addHospital(hospital);
      if (!mounted) return;

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu bệnh viện')),
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Hospital' : 'Add Hospital')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(_nameController, 'Name'),
            const SizedBox(height: 12),
            _buildTextField(_addressController, 'Address'),
            const SizedBox(height: 12),
            _buildNumberField(_ratingController, 'Rating (0-5)', isDouble: true),
            const SizedBox(height: 12),
            _buildNumberField(_reviewCountController, 'Review Count'),
            const SizedBox(height: 12),
            _buildNumberField(_distanceController, 'Distance (km)', isDouble: true),
            const SizedBox(height: 12),
            _buildNumberField(_etaController, 'ETA (minutes)'),
            const SizedBox(height: 12),
            _buildTextField(_typeController, 'Type Label'),
            const SizedBox(height: 12),
            _buildTextField(_imagePathController, 'Image Asset Path'),
            SwitchListTile(
              value: _isBookmarked,
              onChanged: (value) => setState(() => _isBookmarked = value),
              title: const Text('Is Bookmarked'),
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
    String label,
  ) {
    return TextFormField(
      controller: controller,
      validator: (value) {
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

  Widget _buildNumberField(
    TextEditingController controller,
    String label, {
    bool isDouble = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $label';
        }
        final number = isDouble
            ? double.tryParse(value.trim())
            : int.tryParse(value.trim());
        if (number == null) {
          return 'Giá trị $label không hợp lệ';
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

