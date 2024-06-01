import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormWidget extends StatelessWidget {
  final TextInputType textInputType;
  final IconData prefixIcon;
  final String hintText;
  const TextFormWidget({
    super.key,
    required this.textInputType,
    required this.prefixIcon,
    required this.hintText, required TextEditingController controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enableSuggestions: true,
      autocorrect: true,
      keyboardType: textInputType,
      validator: (value) {
        if (value!.isEmpty) {
          print('Enter $hintText');
          return 'Enter $hintText';
        }
        return null;
      },
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.green,
        ),
        suffixIcon: SizedBox(
          width: 60,
          child: GestureDetector(
            // onTap: emailController.clear,
            child: const Icon(
              Icons.close,
              color: Colors.green,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade200,
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.green,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.green,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}