import 'package:flutter/material.dart';

// Minimal placeholder for a dynamic Doctype form renderer.
// For now it supports only basic text/date/select fields passed via
// `fields` parameter; API fetching should be done by parent for flexibility.

class DoctypeForm extends StatefulWidget {
  final String title;
  final List<FormFieldSpec> fields;
  final void Function(Map<String, dynamic> values) onSubmit;

  const DoctypeForm({super.key, required this.title, required this.fields, required this.onSubmit});

  @override
  State<DoctypeForm> createState() => _DoctypeFormState();
}

class _DoctypeFormState extends State<DoctypeForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      _values[f.name] = f.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final f in widget.fields) _buildField(f),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(_values);
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
            )
          ],
        ),
      ),
    );
  }

  bool _evalDependsOn(String? expr) {
    if (expr == null || expr.trim().isEmpty) return true;
    // very simple expression: field==value or field!=value
    try {
      if (expr.contains('==')) {
        final parts = expr.split('==');
        final left = parts[0].trim();
        final right = parts[1].trim();
        return (_values[left]?.toString() ?? '') == right;
      }
      if (expr.contains('!=')) {
        final parts = expr.split('!=');
        final left = parts[0].trim();
        final right = parts[1].trim();
        return (_values[left]?.toString() ?? '') != right;
      }
    } catch (_) {}
    return true;
  }

  Widget _buildField(FormFieldSpec f) {
    if (f.hidden == true) return const SizedBox.shrink();
    if (!_evalDependsOn(f.dependsOn)) return const SizedBox.shrink();
    switch (f.type) {
      case FieldType.text:
        return TextFormField(
          decoration: InputDecoration(labelText: f.label),
          initialValue: _values[f.name]?.toString() ?? '',
          validator: f.required ? (v) => (v == null || v.isEmpty) ? '${f.label} required' : null : null,
          onSaved: (v) => _values[f.name] = v,
        );
      case FieldType.number:
        return TextFormField(
          decoration: InputDecoration(labelText: f.label),
          initialValue: _values[f.name]?.toString() ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: f.required ? (v) => (v == null || v.isEmpty) ? '${f.label} required' : null : null,
          onSaved: (v) => _values[f.name] = double.tryParse(v ?? ''),
        );
      case FieldType.select:
        return DropdownButtonFormField<String>(
          value: (_values[f.name] as String?) ?? (f.options?.isNotEmpty == true ? f.options!.first : null),
          items: (f.options ?? []).map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (v) => setState(() => _values[f.name] = v),
          decoration: InputDecoration(labelText: f.label),
          validator: f.required ? (v) => (v == null || v.isEmpty) ? '${f.label} required' : null : null,
        );
      case FieldType.date:
        final controller = TextEditingController(text: _values[f.name]?.toString() ?? '');
        return TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(labelText: f.label),
          validator: f.required ? (v) => (v == null || v.isEmpty) ? '${f.label} required' : null : null,
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(context: context, firstDate: DateTime(now.year - 2), lastDate: DateTime(now.year + 2), initialDate: now);
            if (picked != null) {
              setState(() {
                controller.text = picked.toIso8601String().substring(0, 10);
                _values[f.name] = controller.text;
              });
            }
          },
        );
      case FieldType.check:
        bool init = (_values[f.name] as bool?) ?? false;
        return CheckboxListTile(
          value: init,
          onChanged: (v) => setState(()=> _values[f.name] = v ?? false),
          title: Text(f.label),
          controlAffinity: ListTileControlAffinity.leading,
        );
      case FieldType.section:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(f.label, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
    }
  }
}

class FormFieldSpec {
  final String name;
  final String label;
  final FieldType type;
  final bool required;
  final List<String>? options;
  final dynamic initialValue;
  final String? dependsOn;
  final bool? hidden;

  FormFieldSpec({required this.name, required this.label, required this.type, this.required = false, this.options, this.initialValue, this.dependsOn, this.hidden});
}

enum FieldType { text, number, select, date, check, section }
