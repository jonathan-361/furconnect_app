import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class EmojiPickerWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final VoidCallback onEmojiSelected;

  const EmojiPickerWidget({
    Key? key,
    required this.textEditingController,
    required this.onEmojiSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmojiPicker(
      textEditingController: textEditingController,
      config: Config(
        height: 256,
        checkPlatformCompatibility: true,
        emojiViewConfig: const EmojiViewConfig(
          backgroundColor: Colors.white,
        ),
        skinToneConfig: const SkinToneConfig(),
        categoryViewConfig: CategoryViewConfig(
          backgroundColor: Colors.white,
          dividerColor: Colors.white,
          indicatorColor: Colors.blue,
          iconColorSelected: Colors.black,
          iconColor: Colors.grey,
        ),
        bottomActionBarConfig: const BottomActionBarConfig(
          backgroundColor: Colors.white,
          buttonColor: Colors.white,
          buttonIconColor: Colors.grey,
        ),
        searchViewConfig: SearchViewConfig(
          backgroundColor: Colors.white,
        ),
      ),
      onEmojiSelected: (emoji, category) {
        onEmojiSelected();
      },
    );
  }
}
