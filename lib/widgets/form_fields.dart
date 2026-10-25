import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/validation.dart';
import 'shop_widgets.dart';

class ShopField extends StatelessWidget {
  const ShopField(
    this.label, {
    super.key,
    this.controller,
    this.initialValue,
    this.onSaved,
    this.validator = Validate.required,
    this.keyboard,
    this.obscure = false,
    this.maxLength,
    this.formatters,
  });
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboard;
  final bool obscure;
  final int? maxLength;
  final List<TextInputFormatter>? formatters;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextFormField(
      controller: controller,
      initialValue: initialValue,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboard,
      obscureText: obscure,
      autocorrect: !obscure,
      enableSuggestions: !obscure,
      maxLength: maxLength,
      inputFormatters: formatters,
      decoration: InputDecoration(labelText: label, counterText: ''),
    ),
  );
}

class CardForm extends StatefulWidget {
  const CardForm({super.key, required this.formKey, required this.onValid});
  final GlobalKey<FormState> formKey;
  final ValueChanged<String> onValid;
  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  String number = '';
  @override
  Widget build(BuildContext context) => Form(
    key: widget.formKey,
    child: SurfaceCard(
      child: Column(
        children: [
          ShopField(
            'Credit Card Number',
            keyboard: TextInputType.number,
            maxLength: 23,
            validator: Validate.card,
            onSaved: (value) {
              number = value!.replaceAll(' ', '');
              widget.onValid(number.substring(number.length - 4));
            },
          ),
          const ShopField('Cardholder Name'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: ShopField(
                  'Expiration Date (MM/YY)',
                  keyboard: TextInputType.datetime,
                  validator: Validate.expiry,
                  maxLength: 5,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShopField(
                  'CVV',
                  obscure: true,
                  keyboard: TextInputType.number,
                  maxLength: 4,
                  validator: (value) =>
                      RegExp(r'^\d{3,4}$').hasMatch(value ?? '')
                      ? null
                      : '3–4 digits',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
