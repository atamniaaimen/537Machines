import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_colors.dart';
import '../../common/app_text_styles.dart';
import '../../common/ui_helpers.dart';
import '../../common/validators.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'edit_profile_viewmodel.dart';

class EditProfileView extends StackedView<EditProfileViewModel> {
  const EditProfileView({super.key});

  @override
  Widget builder(
    BuildContext context,
    EditProfileViewModel viewModel,
    Widget? child,
  ) {
    final user = viewModel.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Not logged in')),
      );
    }

    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final companyController = TextEditingController(text: user.company);
    final phoneController = TextEditingController(text: user.phone);
    final locationController = TextEditingController(text: user.location);
    final bioController = TextEditingController(text: user.bio);
    final emailController = TextEditingController(text: user.email);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.gray150),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // Avatar with change photo
              GestureDetector(
                onTap: viewModel.pickAvatar,
                child: Column(
                  children: [
                    if (viewModel.pickedAvatar != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            FileImage(viewModel.pickedAvatar!),
                      )
                    else
                      AvatarWidget(
                        initials: user.initials,
                        photoUrl: user.photoUrl.isNotEmpty
                            ? user.photoUrl
                            : null,
                        size: AvatarSize.lg,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Change Photo',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
              verticalSpaceLarge,

              // First Name + Last Name row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: firstNameController,
                      label: 'First Name',
                      validator: (v) =>
                          Validators.validateRequired(v, 'First name'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: lastNameController,
                      label: 'Last Name',
                      validator: (v) =>
                          Validators.validateRequired(v, 'Last name'),
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Email (read-only)
              CustomTextField(
                controller: emailController,
                label: 'Email',
                enabled: false,
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: companyController,
                label: 'Company',
                hint: 'Your company name',
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: phoneController,
                label: 'Phone',
                hint: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: locationController,
                label: 'Location',
                hint: 'e.g. New York, NY',
              ),
              verticalSpaceMedium,

              CustomTextField(
                controller: bioController,
                label: 'Bio',
                hint: 'Tell us about yourself...',
                maxLines: 3,
              ),

              verticalSpaceLarge,

              if (viewModel.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    viewModel.modelError.toString(),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),

              CustomButton(
                title: 'Save Profile',
                size: ButtonSize.lg,
                isLoading: viewModel.isBusy,
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    viewModel.save(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      company: companyController.text.trim(),
                      phone: phoneController.text.trim(),
                      location: locationController.text.trim(),
                      bio: bioController.text.trim(),
                    );
                  }
                },
              ),
              verticalSpaceLarge,
            ],
          ),
        ),
      ),
    );
  }

  @override
  EditProfileViewModel viewModelBuilder(BuildContext context) =>
      EditProfileViewModel();
}
