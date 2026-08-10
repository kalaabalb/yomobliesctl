// lib/widgets/camera_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPickerDialog extends StatelessWidget {
  final Function(XFile?) onImageSelected;

  const CameraPickerDialog({
    Key? key,
    required this.onImageSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Select Image Source',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionButton(
            context,
            icon: Icons.camera_alt,
            title: 'Camera',
            onTap: () => _pickImage(ImageSource.camera, context),
          ),
          SizedBox(height: 12),
          _buildOptionButton(
            context,
            icon: Icons.photo_library,
            title: 'Gallery',
            onTap: () => _pickImage(ImageSource.gallery, context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.blue[50],
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          child: Row(
            children: [
              Icon(icon, color: Colors.blue[600], size: 24),
              SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[800],
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Colors.blue[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(ImageSource source, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      Navigator.of(context).pop();
      onImageSelected(image);
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Usage function
void showCameraPickerDialog(
    BuildContext context, Function(XFile?) onImageSelected) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CameraPickerDialog(onImageSelected: onImageSelected);
    },
  );
}
