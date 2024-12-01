

// Widget CafeTextFormField() {
//   return TextFormField(
//     focusNode: _otpFocusNode,
//     enabled: otpSent,
//     autovalidateMode: AutovalidateMode.onUserInteraction,
//     controller: _otpController,
//     validator: (value) {
//       if (value!.isEmpty || value.length < 6) {
//         return 'Please enter a valid OTP';
//       }

//       return null;
//     },
//     keyboardType: TextInputType.phone,
//     maxLength: 10,
//     decoration: InputDecoration(hintText: 'OTP', counterText: ''),
//   );
// }
