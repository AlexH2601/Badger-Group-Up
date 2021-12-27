import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Quick build text input
///
class TextFieldFactory {
  static Widget buildText(String content,
      {int lines = 1}) {
    return Container(
      margin: const EdgeInsets.all(12),
      height: lines * 24.0,
      child: Center(child: Text(content)),
    );
  }

  static Widget buildTextField(
      TextEditingController? controller, String inputHint,
      {bool isObscure = false, int lines = 1}) {
    return Container(
      margin: const EdgeInsets.all(12),
      height: lines * 24.0,
      child: TextField(
       // scrollPadding: EdgeInsets.only(bottom: User.screenHeightPixels),
        maxLines: lines,
        controller: controller,
        decoration: InputDecoration(
          labelText: inputHint,
          fillColor: Colors.grey[300],
          filled: (lines > 1),
        ),
        obscureText: isObscure,
        // onEditingComplete: ,
      ),
    );
  }

  static Widget buildNumericField(
      TextEditingController? controller, String inputHint,
      {bool isObscure = false, int lines = 1}) {
    return Container(
      margin: const EdgeInsets.all(12),
      height: lines * 24.0,
      child: TextField(
          maxLines: lines,
          controller: controller,
          decoration: InputDecoration(
              labelText: inputHint),
          obscureText: isObscure,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ]),
    );
  }
}
