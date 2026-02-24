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

  static final _formKey = GlobalKey<FormState>();

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
          key: _formKey,
          child: Column(
            children: [
              // Avatar with change photo
              GestureDetector(
                onTap: viewModel.pickAvatar,
                child: Column(
                  children: [
                    if (viewModel.pickedAvatarBytes != null)
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            MemoryImage(viewModel.pickedAvatarBytes!),
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
                      initialValue: viewModel.firstName,
                      label: 'First Name',
                      onChanged: viewModel.setFirstName,
                      validator: (v) =>
                          Validators.validateRequired(v, 'First name'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      initialValue: viewModel.lastName,
                      label: 'Last Name',
                      onChanged: viewModel.setLastName,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Last name'),
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Email (read-only)
              CustomTextField(
                initialValue: viewModel.email,
                label: 'Email',
                enabled: false,
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.company,
                label: 'Company',
                hint: 'Your company name',
                onChanged: viewModel.setCompany,
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.phone,
                label: 'Phone',
                hint: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
                onChanged: viewModel.setPhone,
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.location,
                label: 'Location',
                hint: 'e.g. New York, NY',
                onChanged: viewModel.setLocation,
              ),
              verticalSpaceMedium,

              CustomTextField(
                initialValue: viewModel.bio,
                label: 'Bio',
                hint: 'Tell us about yourself...',
                maxLines: 3,
                onChanged: viewModel.setBio,
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
                  if (_formKey.currentState!.validate()) {
                    viewModel.save();
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

  @override
  void onViewModelReady(EditProfileViewModel viewModel) =>
      viewModel.initFields();
}
