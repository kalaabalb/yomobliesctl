import '../../../utility/responsive_utils.dart';
import '../../../widgets/compact_form_dialog.dart';
import '../provider/poster_provider.dart';
import '../../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../../../models/poster.dart';
import '../../../utility/constants.dart';
import '../../../widgets/category_image_card.dart';
import '../../../widgets/custom_text_field.dart';

class PosterSubmitForm extends StatelessWidget {
  final Poster? poster;

  const PosterSubmitForm({super.key, this.poster});

  @override
  Widget build(BuildContext context) {
    context.posterProvider.setDataForUpdatePoster(poster);
    return Padding(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context)),
      child: Form(
        key: context.posterProvider.addPosterFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSection(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildNameField(context),
            Gap(ResponsiveUtils.getPadding(context)),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (context, posterProvider, child) {
        return Column(
          children: [
            SizedBox(
              width: ResponsiveUtils.isMobile(context) ? 120 : 150,
              child: CategoryImageCard(
                labelText: "Poster",
                imageFile: posterProvider.selectedImage,
                imageUrlForUpdateImage: poster?.imageUrl,
                onTap: () {
                  posterProvider.pickImage(context);
                },
                onRemoveImage: () {
                  posterProvider.selectedImage = null;
                  posterProvider.imgXFile = null;
                  posterProvider.notifyListeners();
                },
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add poster image',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNameField(BuildContext context) {
    return CustomTextField(
      controller: context.posterProvider.posterNameCtrl,
      labelText: 'Poster Name',
      onSave: (val) {},
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a poster name';
        }
        return null;
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: secondaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          Gap(ResponsiveUtils.getPadding(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (context.posterProvider.addPosterFormKey.currentState!
                  .validate()) {
                context.posterProvider.addPosterFormKey.currentState!.save();
                context.posterProvider.submitPoster();
                Navigator.of(context).pop();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

void showAddPosterForm(BuildContext context, Poster? poster) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CompactFormDialog(
        title: 'Add Poster',
        child: PosterSubmitForm(poster: poster),
      );
    },
  );
}
