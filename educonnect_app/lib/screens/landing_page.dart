import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/auth_provider.dart';
import '../providers/toast_provider.dart';
import '../utils/routes.dart';
import '../utils/theme.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeInOut),
    );
    _cardAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(_emailController.text, _passwordController.text);
      
      if (!mounted) return;
      
      final toastProvider = context.read<ToastProvider>();
      toastProvider.showSuccess('Login successful!');
      
      // Navigate based on role
      await Future.delayed(const Duration(milliseconds: 500));
      
      final route = authProvider.getInitialRoute();
      Navigator.of(context).pushReplacementNamed(route);
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
    final size = MediaQuery.of(context).size;
    
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  SizedBox(height: size.height * 0.05),
                  
                  // Main Content
                  Row(
                    children: [
                      // Login Form (Left Side)
                      Expanded(
                        flex: 1,
                        child: _buildLoginForm(),
                      ),
                      
                      const SizedBox(width: 40),
                      
                      // Animated Cards (Right Side)
                      Expanded(
                        flex: 1,
                        child: _buildAnimatedCards(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimationLimiter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            const Text(
              'EduConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            CustomButton(
              text: 'Sign Up',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            Container(
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
                            Icons.school,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to your EduConnect portal',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hintText: 'Enter your college email',
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
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Enter your password',
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () {
                        setState(() => _isPasswordVisible = !_isPasswordVisible);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    CustomButton(
                      text: _isLoading ? 'Signing in...' : 'Sign In',
                      onPressed: _isLoading ? null : _handleLogin,
                      variant: ButtonVariant.primary,
                      isLoading: _isLoading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Color(0xFF059669)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                          child: const Text(
                            'Sign up',
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
    );
  }

  Widget _buildAnimatedCards() {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 800),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 100.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _cardAnimation.value * 20),
                        child: _buildUserTypeCard(
                          'For Students',
                          'Access learning resources, connect with peers, and build your professional network',
                          Icons.school,
                          AppGradients.primaryGradient,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(20, -_cardAnimation.value * 15 + 60),
                        child: _buildUserTypeCard(
                          'For Professors',
                          'Manage courses, track student progress, and collaborate with faculty members',
                          Icons.person,
                          AppGradients.blueGradient,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(40, _cardAnimation.value * 10 + 120),
                        child: _buildUserTypeCard(
                          'For Alumni',
                          'Stay connected with your alma mater and mentor the next generation',
                          Icons.groups,
                          AppGradients.purpleGradient,
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _cardAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(60, -_cardAnimation.value * 25 + 180),
                        child: _buildUserTypeCard(
                          'For Management',
                          'Oversee operations, manage resources, and drive institutional growth',
                          Icons.business,
                          AppGradients.orangeGradient,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String title, String description, IconData icon, Gradient gradient) {
    return Container(
      width: 280,
      height: 320,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}