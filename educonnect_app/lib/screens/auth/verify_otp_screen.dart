import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../services/api_service.dart';
import '../../utils/routes.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _timeLeft = 300; // 5 minutes
  late String _email;
  
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 300),
      vsync: this,
    );
    _timerAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_timerController);
    _timerController.forward();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _email = args?['email'] ?? '';
    
    if (_email.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.register);
      });
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          }
        });
        return _timeLeft > 0;
      }
      return false;
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 4) {
      context.read<ToastProvider>().showError('Please enter a valid 4-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ApiService.verifyOTP(_email, _otpController.text);
      
      if (!mounted) return;
      
      context.read<ToastProvider>().showSuccess('Email verified successfully!');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isResending = true);

    try {
      await ApiService.resendOTP(_email);
      
      if (!mounted) return;
      
      context.read<ToastProvider>().showSuccess('OTP sent successfully!');
      setState(() {
        _timeLeft = 300;
        _timerController.reset();
        _timerController.forward();
      });
      _startTimer();
    } catch (error) {
      if (!mounted) return;
      context.read<ToastProvider>().showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
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
                        constraints: const BoxConstraints(maxWidth: 400),
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
                                    Icons.mail_outline,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Verify Your Email',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "We've sent a 4-digit code to",
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _email,
                                  style: const TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // OTP Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter OTP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF047857),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 8,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0000',
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFD1FAE5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFD1FAE5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 4) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Timer or Resend
                            Center(
                              child: _timeLeft > 0
                                  ? Column(
                                      children: [
                                        Text(
                                          'Time remaining: ${_formatTime(_timeLeft)}',
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        AnimatedBuilder(
                                          animation: _timerAnimation,
                                          builder: (context, child) {
                                            return LinearProgressIndicator(
                                              value: _timerAnimation.value,
                                              backgroundColor: const Color(0xFFD1FAE5),
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  : TextButton.icon(
                                      onPressed: _isResending ? null : _handleResendOtp,
                                      icon: _isResending
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.refresh),
                                      label: Text(_isResending ? 'Resending...' : 'Resend OTP'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF059669),
                                      ),
                                    ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Verify Button
                            CustomButton(
                              text: _isLoading ? 'Verifying...' : 'Verify Email',
                              onPressed: (_isLoading || _otpController.text.length != 4) ? null : _handleVerifyOtp,
                              variant: ButtonVariant.primary,
                              isLoading: _isLoading,
                            ),
                          ],
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
}