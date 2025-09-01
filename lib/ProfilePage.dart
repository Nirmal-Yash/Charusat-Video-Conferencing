import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  const ProfilePage({super.key, required this.userInfo});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _collegeIdController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _courseController;
  String _selectedYear = '1st Year';
  bool _isEditing = false;

  final List<String> yearOptions = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userInfo['studentName'] ?? '');
    _collegeIdController =
        TextEditingController(text: widget.userInfo['collegeId'] ?? '');
    _emailController =
        TextEditingController(text: widget.userInfo['email'] ?? '');
    _phoneController =
        TextEditingController(text: widget.userInfo['phone'] ?? '');
    _courseController =
        TextEditingController(text: widget.userInfo['course'] ?? '');
    _selectedYear = widget.userInfo['year'] ?? '1st Year';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text("My Profile",
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Switch(
              value: _isEditing,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.grey,
              onChanged: (val) {
                setState(() => _isEditing = val);
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 20),
                _customField('Full Name', _nameController, Icons.person),
                _customField('College ID', _collegeIdController, Icons.badge),
                _customField('Email', _emailController, Icons.email,
                    type: TextInputType.emailAddress),
                _customField('Phone', _phoneController, Icons.phone,
                    type: TextInputType.phone),
                _customField('Course', _courseController, Icons.school),
                _customDropdown(),
                const SizedBox(height: 20),
                _isEditing
                    ? ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Save logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profile updated!")),
                      );
                      setState(() => _isEditing = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 30),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _customField(String label, TextEditingController controller,
      IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        enabled: _isEditing,
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[200],
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _customDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Year',
          prefixIcon: const Icon(Icons.timeline),
          filled: true,
          fillColor: _isEditing ? Colors.white : Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedYear,
            items: yearOptions
                .map((year) =>
                DropdownMenuItem(value: year, child: Text(year)))
                .toList(),
            onChanged: _isEditing
                ? (val) => setState(() => _selectedYear = val!)
                : null,
          ),
        ),
      ),
    );
  }
}
