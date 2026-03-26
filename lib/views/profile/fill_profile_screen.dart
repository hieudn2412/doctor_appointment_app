import 'package:doctor_appointment_app/domain/entities/user.dart';
import 'package:doctor_appointment_app/viewmodels/login/auth_viewmodel.dart';
import 'package:doctor_appointment_app/views/home/home_screen.dart';
import 'package:doctor_appointment_app/views/profile/fill_profile_success_dialog.dart';
import 'package:flutter/material.dart';

class FillProfileScreen extends StatefulWidget {
  const FillProfileScreen({super.key, this.isFirstTimeSetup = false});

  final bool isFirstTimeSetup;

  @override
  State<FillProfileScreen> createState() => _FillProfileScreenState();
}

class _FillProfileScreenState extends State<FillProfileScreen> {
  static const String _profileAsset = 'assets/images/profile.png';

  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthController = TextEditingController();
  String? _gender;
  User? _currentUser;

  final _authViewModel = AuthViewModel();
  bool _isLoading = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    final user =
        await _authViewModel.reloadCurrentUserByEmail() ??
        _authViewModel.currentUser;
    if (!mounted) return;

    _currentUser = user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _addressController.text = user?.address ?? '';
    _birthController.text = user?.birthDate ?? '';

    setState(() {
      _gender = user?.gender;
      _isInitializing = false;
    });
  }

  Future<void> _onSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập họ và tên'),
          backgroundColor: Color(0xFFEF4444), // Màu đỏ thông báo lỗi
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final email = (_currentUser?.email ?? _authViewModel.currentUserEmail)
        ?.trim()
        .toLowerCase();
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy thông tin đăng nhập hiện tại'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authViewModel.updateProfile(
      email: email,
      name: name,
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      birthDate: _birthController.text.trim(),
      gender: _gender,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _currentUser = await _authViewModel.reloadCurrentUserByEmail();
      if (!mounted) return;

      if (widget.isFirstTimeSetup) {
        await FillProfileSuccessDialog.show(context);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          (route) => false,
        );
        return;
      }

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authViewModel.errorMessage ?? 'Lỗi khi lưu hồ sơ'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF292D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'Hoàn thiện hồ sơ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 202,
                        height: 202,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE5E7EB).withValues(alpha: 0.4),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            _profileAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.account_circle_rounded,
                                size: 202,
                                color: Color(0xFFE5E7EB),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C2A3A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _FormInput(controller: _nameController, hint: 'Họ và tên'),
                  const SizedBox(height: 20),
                  _FormInput(
                    controller: _phoneController,
                    hint: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _FormInput(controller: _addressController, hint: 'Địa chỉ'),
                  const SizedBox(height: 20),
                  _FormInput(
                    controller: _birthController,
                    hint: 'Ngày sinh',
                    prefixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        _birthController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _gender,
                        isExpanded: true,
                        hint: const Text(
                          'Giới tính',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF9CA3AF),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                          DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                          DropdownMenuItem(value: 'Khác', child: Text('Khác')),
                        ],
                        onChanged: (value) => setState(() => _gender = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (_isLoading || _isInitializing)
                          ? null
                          : _onSave,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF1C2A3A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(55),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Lưu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.onTap,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onTap: onTap,
        readOnly: onTap != null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF9CA3AF),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixIcon,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1C2A3A)),
          ),
        ),
      ),
    );
  }
}
