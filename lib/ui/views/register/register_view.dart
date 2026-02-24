import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../widgets/logo_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../common/validators.dart';
import 'register_viewmodel.dart';

class RegisterView extends StackedView<RegisterViewModel> {
  const RegisterView({super.key});

  static final _formKey = GlobalKey<FormState>();

  @override
  Widget builder(
    BuildContext context,
    RegisterViewModel viewModel,
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
                  const LogoWidget(size: LogoSize.lg),
                  const SizedBox(height: 32),

                  Text(
                    'Create Account',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join the industrial marketplace',
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray400,
                    ),
                  ),
                  const SizedBox(height: 32),

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

                  // First + Last name row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'First Name',
                          hint: 'John',
                          onChanged: viewModel.setFirstName,
                          validator: Validators.validateName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Last Name',
                          hint: 'Smith',
                          onChanged: viewModel.setLastName,
                          validator: Validators.validateName,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Email',
                    hint: 'you@company.com',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: viewModel.setEmail,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Company',
                    hint: 'Your company name',
                    onChanged: viewModel.setCompany,
                  ),
                  const SizedBox(height: 20),

                  // Role selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I want to',
                        style: GoogleFonts.titilliumWeb(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _RoleChip(
                            label: 'Buy',
                            isSelected: viewModel.role == 'buyer',
                            onTap: () => viewModel.setRole('buyer'),
                          ),
                          const SizedBox(width: 8),
                          _RoleChip(
                            label: 'Sell',
                            isSelected: viewModel.role == 'seller',
                            onTap: () => viewModel.setRole('seller'),
                          ),
                          const SizedBox(width: 8),
                          _RoleChip(
                            label: 'Both',
                            isSelected: viewModel.role == 'both',
                            onTap: () => viewModel.setRole('both'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Password',
                    hint: 'Min. 8 characters',
                    onChanged: viewModel.setPassword,
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
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 24),

                  CustomButton(
                    title: 'Create Account',
                    size: ButtonSize.lg,
                    isLoading: viewModel.isBusy,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        viewModel.signUp();
                      }
                    },
                  ),

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

                  CustomButton(
                    title: 'Continue with Google',
                    variant: ButtonVariant.ghost,
                    isLoading: viewModel.isBusy,
                    onTap: viewModel.signInWithGoogle,
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 13,
                            color: AppColors.gray400,
                          ),
                        ),
                        GestureDetector(
                          onTap: viewModel.navigateToLogin,
                          child: Text(
                            'Sign In',
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
  RegisterViewModel viewModelBuilder(BuildContext context) =>
      RegisterViewModel();
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryPale : AppColors.gray50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.titilliumWeb(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primaryDark : AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}
