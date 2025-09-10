import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../utils/routes.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  
  String _selectedRole = 'student';
  String _selectedDepartment = '';
  String _selectedClass = '';
  String _selectedGraduationYear = '';
  String _selectedBatch = '';
  
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final List<String> _departments = [
    'Computer Science Engineering',
    'Information Technology',
    'Electronics and Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
  ];

  final List<String> _classes = ['I', 'II', 'III', 'IV'];
  final List<String> _years = ['2018', '2019', '2020', '2021', '2022', '2023', '2024'];
  final List<String> _batches = ['A', 'B', 'C'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_selectedDepartment.isEmpty) {
      context.read<ToastProvider>().showError('Please select a department');
      return false;
    }

    if (_selectedRole == 'student' && _selectedClass.isEmpty) {
      context.read<ToastProvider>().showError('Please select a class');
      return false;
    }

    if (_selectedRole == 'alumni') {
      if (_selectedGraduationYear.isEmpty) {
        context.read<ToastProvider>().showError('Please select graduation year');
        return false;
      }
      if (_selectedBatch.isEmpty) {
        context.read<ToastProvider>().showError('Please select batch');
        return false;
      }
      if (_companyController.text.trim().isEmpty) {
        context.read<ToastProvider>().showError('Please enter company name');
        return false;
      }
    }

    if (_selectedRole != 'alumni' && !_emailController.text.endsWith('@stjosephstechnology.ac.in')) {
      context.read<ToastProvider>().showError('Please use your college email address (@stjosephstechnology.ac.in)');
      return false;
    }

    return true;
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      final userData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'department': _selectedDepartment,
        'role': _selectedRole,
      };

      if (_selectedRole != 'alumni') {
        userData['password'] = _passwordController.text;
      }

      if (_selectedRole == 'student') {
        userData['className'] = _selectedClass;
      } else if (_selectedRole == 'alumni') {
        userData['graduationYear'] = _selectedGraduationYear;
        userData['batch'] = _selectedBatch;
        userData['placedCompany'] = _companyController.text.trim();
      }

      await authProvider.register(userData);
      
      if (!mounted) return;
      
      final toastProvider = context.read<ToastProvider>();
      
      if (_selectedRole == 'alumni') {
        toastProvider.showInfo('Alumni registration submitted successfully! Please wait for management approval to access the platform.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        toastProvider.showSuccess('Registration successful! Please verify your email.');
        Navigator.pushNamed(
          context, 
          AppRoutes.verifyOtp,
          arguments: {'email': _emailController.text.trim()},
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFF0FDF4),
              Color(0xFFDCFCE7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header
                              Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.person_add,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Join the smart assessment platform',
                                    style: TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Role Selection
                              CustomDropdown(
                                label: 'Role',
                                value: _selectedRole,
                                items: const [
                                  DropdownMenuItem(value: 'student', child: Text('Student')),
                                  DropdownMenuItem(value: 'professor', child: Text('Professor')),
                                  DropdownMenuItem(value: 'alumni', child: Text('Alumni')),
                                ],
                                onChanged: (value) {
                                  setState(() => _selectedRole = value!);
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Name and Email
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _nameController,
                                      label: 'Full Name',
                                      hintText: 'Enter your full name',
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _emailController,
                                      label: 'Email Address',
                                      hintText: _selectedRole == 'alumni' 
                                          ? 'Enter your email' 
                                          : 'Enter your college email',
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password and Phone
                              Row(
                                children: [
                                  if (_selectedRole != 'alumni') ...[
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hintText: 'Create a password',
                                        isPassword: true,
                                        isPasswordVisible: _isPasswordVisible,
                                        onTogglePassword: () {
                                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  Expanded(
                                    child: CustomTextField(
                                      controller: _phoneController,
                                      label: 'Phone Number',
                                      hintText: 'Enter your phone number',
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Phone number is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Department and Class/Alumni fields
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomDropdown(
                                      label: 'Department',
                                      value: _selectedDepartment,
                                      items: [
                                        const DropdownMenuItem(value: '', child: Text('Select Department')),
                                        ..._departments.map((dept) => DropdownMenuItem(
                                          value: dept,
                                          child: Text(dept),
                                        )),
                                      ],
                                      onChanged: (value) {
                                        setState(() => _selectedDepartment = value!);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (_selectedRole == 'student')
                                    Expanded(
                                      child: CustomDropdown(
                                        label: 'Class',
                                        value: _selectedClass,
                                        items: [
                                          const DropdownMenuItem(value: '', child: Text('Select Class')),
                                          ..._classes.map((cls) => DropdownMenuItem(
                                            value: cls,
                                            child: Text(cls),
                                          )),
                                        ],
                                        onChanged: (value) {
                                          setState(() => _selectedClass = value!);
                                        },
                                      ),
                                    )
                                  else if (_selectedRole == 'alumni')
                                    Expanded(
                                      child: CustomDropdown(
                                        label: 'Graduation Year',
                                        value: _selectedGraduationYear,
                                        items: [
                                          const DropdownMenuItem(value: '', child: Text('Select Year')),
                                          ..._years.map((year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year),
                                          )),
                                        ],
                                        onChanged: (value) {
                                          setState(() => _selectedGraduationYear = value!);
                                        },
                                      ),
                                    )
                                  else
                                    const Expanded(child: SizedBox()),
                                ],
                              ),
                              
                              if (_selectedRole == 'alumni') ...[
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomDropdown(
                                        label: 'Batch',
                                        value: _selectedBatch,
                                        items: [
                                          const DropdownMenuItem(value: '', child: Text('Select Batch')),
                                          ..._batches.map((batch) => DropdownMenuItem(
                                            value: batch,
                                            child: Text(batch),
                                          )),
                                        ],
                                        onChanged: (value) {
                                          setState(() => _selectedBatch = value!);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _companyController,
                                        label: 'Current Company',
                                        hintText: 'Enter your current company name',
                                        validator: (value) {
                                          if (_selectedRole == 'alumni' && (value == null || value.isEmpty)) {
                                            return 'Company name is required for alumni';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              
                              const SizedBox(height: 32),
                              
                              // Register Button
                              CustomButton(
                                text: _isLoading ? 'Creating Account...' : 'Create Account',
                                onPressed: _isLoading ? null : _handleRegister,
                                variant: ButtonVariant.primary,
                                isLoading: _isLoading,
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Already have an account? ',
                                    style: TextStyle(color: Color(0xFF059669)),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                                    child: const Text(
                                      'Sign in',
                                      style: TextStyle(
                                        color: Color(0xFF047857),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      final userData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'department': _selectedDepartment,
        'role': _selectedRole,
      };

      if (_selectedRole != 'alumni') {
        userData['password'] = _passwordController.text;
      }

      if (_selectedRole == 'student') {
        userData['className'] = _selectedClass;
      } else if (_selectedRole == 'alumni') {
        userData['graduationYear'] = _selectedGraduationYear;
        userData['batch'] = _selectedBatch;
        userData['placedCompany'] = _companyController.text.trim();
      }

      await authProvider.register(userData);
      
      if (!mounted) return;
      
      final toastProvider = context.read<ToastProvider>();
      
      if (_selectedRole == 'alumni') {
        toastProvider.showInfo('Alumni registration submitted successfully! Please wait for management approval to access the platform.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        toastProvider.showSuccess('Registration successful! Please verify your email.');
        Navigator.pushNamed(
          context, 
          AppRoutes.verifyOtp,
          arguments: {'email': _emailController.text.trim()},
        );
      }
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}