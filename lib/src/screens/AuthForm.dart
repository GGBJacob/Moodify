import 'package:flutter/material.dart';
import 'package:moodify/src/screens/AuthPage.dart';
import 'package:moodify/src/themes/colors.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final String buttonTitle;
  final String switchText;
  final bool isSignUp;
  final Future<void> Function(
      String email, String password, Function(Result result)) action;
  final VoidCallback switchAction;
  final Future<void> Function() appleAction;

  const AuthForm({
    Key? key,
    required this.title,
    required this.buttonTitle,
    required this.switchText,
    required this.isSignUp,
    required this.action,
    required this.switchAction,
    required this.appleAction,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? resultMessage;
  Color? resultColor;

  void _submit() async {
    setState(() {
      isLoading = true;
      resultMessage = null;
    });
    await widget.action(_emailController.text, _passwordController.text,
        (result) {
      setState(() {
        isLoading = false;
        if (result.isSuccess) {
          resultMessage = widget.isSignUp
              ? "Check your inbox to confirm your email"
              : "Login successful";
          resultColor = Colors.green;
        } else {
          resultMessage = result.error.message;
          resultColor = Colors.red;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
        child: Column(
          children: [
            const Spacer(),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: resultMessage != null
                  ? Text(
                      resultMessage!,
                      key: ValueKey(resultMessage),
                      style: TextStyle(color: resultColor, fontSize: 16),
                    )
                  : const SizedBox(height: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              cursorColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              cursorColor: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? surfaceColorDark
                          : pinkish),
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(widget.buttonTitle,
                      style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            TextButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).brightness == Brightness.dark
                          ? blueish
                          : const Color.fromARGB(255, 174, 117, 136))),
              onPressed: () {
                setState(() {
                  resultMessage = null;
                });
                widget.switchAction();
              },
              child: Text(widget.switchText,
                  style: const TextStyle(color: Colors.white)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
