import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mahattaty/authentication/presentation/controllers/auth_controller.dart';
import 'package:mahattaty/core/generic%20components/mahattaty_alert.dart';
import 'package:mahattaty/core/generic%20components/mahattaty_text_form_field.dart';
import 'package:mahattaty/core/utils/open_dialogs.dart';
import 'package:mahattaty/core/utils/validations.dart';
import '../../../../authentication/domain/entities/User.dart';
import '../../../../core/generic%20components/mahattaty_button.dart';
import '../../Exceptions/settings_exception.dart';
import '../components/change_password_dialog.dart';
import '../controllers/settings_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _usernameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SettingsState>(
      settingsControllerProvider,
      (old, state) {
        if (state.exception != null &&
            state.exception!.action == SettingsErrorAction.editProfile) {
          mahattatyAlertDialog(
            context,
            message: state.exception!.message,
            showCancelButton: false,
            type: MahattatyAlertType.error,
            onOk: () {
              Navigator.of(context).pop();
            },
          );
        }
        if (state.isSuccessful) {
          mahattatyAlertDialog(
            context,
            message: 'Profile updated successfully',
            showCancelButton: false,
            type: MahattatyAlertType.success,
            onOk: () {
              Navigator.of(context).pop();
            },
          );
        }
      },
    );

    final state = ref.watch(settingsControllerProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                child: user?.photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user!.photoUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        FontAwesomeIcons.user,
                        size: 50,
                      ),
              ),
              const SizedBox(height: 16),
              if (user?.isGoogle == true) _googleAccountNotice(context),
              const SizedBox(height: 16),
              _buildUsernameField(user, state),
              const SizedBox(height: 16),
              _buildEmailField(user, state),
              const SizedBox(height: 16),
              MahattatyButton(
                text: 'Change Password',
                onPressed: () {
                  OpenDialogs.openCustomDialog(
                    context: context,
                    dialog: ChangePasswordDialog(
                      onButtonPressed: (password) async {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .changePassword(password);
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
                style: MahattatyButtonStyle.secondary,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MahattatyButton(
                      text: 'Cancel',
                      onPressed: state.isLoading
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: MahattatyButtonStyle.secondary,
                    ),
                  ),
                  const SizedBox(width: 16), // Add spacing between buttons
                  Expanded(
                    child: MahattatyButton(
                      text: 'Save Changes',
                      disabled: state.isLoading,
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate() &&
                                  (_usernameController.text != user?.name ||
                                      _emailController.text != user?.email)) {
                                await ref
                                    .read(settingsControllerProvider.notifier)
                                    .editProfile(
                                      name: _usernameController.text,
                                      email: _emailController.text,
                                    );
                                await ref
                                    .read(authControllerProvider.notifier)
                                    .updateCurrentUser();
                              }
                            },
                      style: MahattatyButtonStyle.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleAccountNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'You are using a Google account, so you can\'t change your email.',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildUsernameField(User? user, SettingsState state) {
    return MahattatyTextFormField(
      controller: _usernameController,
      iconData: Icons.person,
      labelText: 'Username',
      disabled: state.isLoading,
      hintText: 'Enter your username',
      errorText: state.getError(
          SettingsErrorAction.editProfile, SettingsError.invalidUserName),
      validator: (value) => value!.isValidUsername
          ? null
          : 'Invalid input. Please enter a valid username.',
      keyboardType: TextInputType.name,
    );
  }

  Widget _buildEmailField(User? user, SettingsState state) {
    return MahattatyTextFormField(
      controller: _emailController,
      iconData: Icons.email,
      labelText: 'Email',
      disabled: true,
      hintText: 'Enter your email',
      errorText: state.getError(
          SettingsErrorAction.editProfile, SettingsError.invalidEmail),
      validator: (value) => value!.isValidEmail
          ? null
          : 'Invalid input. Please enter a valid email.',
      keyboardType: TextInputType.emailAddress,
    );
  }
}
