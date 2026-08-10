import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utility/constants.dart';

class ProductImageCard extends StatelessWidget {
  final String labelText;
  final File? imageFile;
  final String? imageUrlForUpdateImage;
  final VoidCallback onTap;
  final VoidCallback onRemoveImage;

  const ProductImageCard({
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

    return Container(
      width: 80,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasImage ? primaryColor : Colors.grey.shade600,
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Image content
                  if (hasImage) _buildImageContent() else _buildPlaceholder(),

                  // Camera icon for empty state
                  if (!hasImage)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                            size: 20,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
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
          SizedBox(height: 4),
          Text(
            labelText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Remove button if image exists
          if (hasImage) ...[
            SizedBox(height: 4),
            GestureDetector(
              onTap: onRemoveImage,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 10, color: Colors.white),
                    SizedBox(width: 2),
                    Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
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
        borderRadius: BorderRadius.circular(6),
        child: CachedNetworkImage(
          imageUrl: imageUrlForUpdateImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
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
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
