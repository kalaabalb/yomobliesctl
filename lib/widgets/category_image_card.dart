import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utility/constants.dart';

class CategoryImageCard extends StatelessWidget {
  final String labelText;
  final File? imageFile;
  final String? imageUrlForUpdateImage;
  final VoidCallback onTap;
  final VoidCallback onRemoveImage;

  const CategoryImageCard({
    Key? key,
    required this.labelText,
    required this.imageFile,
    this.imageUrlForUpdateImage,
    required this.onTap,
    required this.onRemoveImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null ||
        (imageUrlForUpdateImage != null &&
            imageUrlForUpdateImage!.isNotEmpty &&
            imageUrlForUpdateImage != 'no_url');

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage ? primaryColor : Colors.grey.shade600,
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Image content
                if (hasImage) _buildImageContent() else _buildPlaceholder(),

                // Camera icon positioned properly
                if (!hasImage)
                  Positioned(
                    top: 30,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.white70,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Label text
        SizedBox(height: 8),
        Text(
          labelText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Remove button if image exists
        if (hasImage) ...[
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRemoveImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size(0, 0),
            ),
            icon: Icon(Icons.delete, size: 16),
            label: Text('Remove'),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent() {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else if (imageUrlForUpdateImage != null &&
        imageUrlForUpdateImage!.isNotEmpty &&
        imageUrlForUpdateImage != 'no_url') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrlForUpdateImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800]!.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(), // Empty container, camera icon is positioned above
    );
  }
}
