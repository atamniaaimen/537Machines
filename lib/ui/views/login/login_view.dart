import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../common/validators.dart';
import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gray150),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  const LogoWidget(size: LogoSize.lg),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to access your marketplace',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Error
                  if (viewModel.hasError) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        viewModel.modelError.toString(),
                        style: GoogleFonts.titilliumWeb(
                          color: AppColors.danger,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Fields
                  CustomTextField(
                    label: 'Email',
                    hint: 'you@company.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: viewModel.setEmail,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Password',
                    hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                    obscureText: viewModel.obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.gray400,
                        size: 20,
                      ),
                      onPressed: viewModel.togglePasswordVisibility,
                    ),
                    onChanged: viewModel.setPassword,
                    validator: Validators.validatePassword,
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),

                  // Sign In
                  CustomButton(
                    title: 'Sign In',
                    size: ButtonSize.lg,
                    isLoading: viewModel.isBusy,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.signIn();
                      }
                    },
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.gray200)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 12,
                              color: AppColors.gray300,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.gray200)),
                      ],
                    ),
                  ),

                  // Google
                  CustomButton(
                    title: 'Continue with Google',
                    variant: ButtonVariant.ghost,
                    isLoading: viewModel.isBusy,
                    onTap: viewModel.signInWithGoogle,
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 13,
                            color: AppColors.gray400,
                          ),
                        ),
                        GestureDetector(
                          onTap: viewModel.navigateToRegister,
                          child: Text(
                            'Register',
                            style: GoogleFonts.titilliumWeb(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
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
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
