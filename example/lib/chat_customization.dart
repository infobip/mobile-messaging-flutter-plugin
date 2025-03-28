library chat_customization;

import 'package:infobip_mobilemessaging/models/configurations/configuration.dart' as mmconfiguration;

Object customBranding = mmconfiguration.ChatCustomization(
  chatStatusBarBackgroundColor: '#673AB7',
  chatStatusBarIconsColorMode: 'dark',
  chatToolbar: mmconfiguration.ToolbarCustomization(
    titleTextAppearance: 'TextAppearance_AppCompat_Title',
    titleTextColor: '#FFFFFF',
    titleText: 'Some new title',
    titleCentered: true,
    backgroundColor: '#673AB7',
    navigationIcon: 'assets/ic_back.png',
    navigationIconTint: '#FFFFFF',
    subtitleTextAppearance: 'TextAppearance_AppCompat_Subtitle',
    subtitleTextColor: '#FFFFFF',
    subtitleText: '#1',
    subtitleCentered: true,
  ),
  attachmentPreviewToolbar: mmconfiguration.ToolbarCustomization(
    titleTextAppearance: 'TextAppearance_AppCompat_Title',
    titleTextColor: '#212121',
    titleText: 'Attachment preview',
    titleCentered: true,
    backgroundColor: '#673AB7',
    navigationIcon: 'assets/ic_back.png',
    navigationIconTint: '#FFFFFF',
    subtitleTextAppearance: 'TextAppearance_AppCompat_Subtitle',
    subtitleTextColor: '#FFFFFF',
    subtitleText: 'Attachment preview subtitle',
    subtitleCentered: false,
  ),
  attachmentPreviewToolbarSaveMenuItemIcon: 'assets/ic_download.png',
  attachmentPreviewToolbarMenuItemsIconTint: '#9E9E9E',
  networkErrorText: 'Network error',
  networkErrorTextColor: '#FFFFFF',
  networkErrorLabelBackgroundColor: '#212121',
  chatBackgroundColor: '#FFFFFF',
  chatProgressBarColor: '#9E9E9E',
  chatInputTextAppearance: 'TextAppearance_AppCompat',
  chatInputTextColor: '#212121',
  chatInputBackgroundColor: '#D1C4E9',
  chatInputHintText: 'Input Message',
  chatInputHintTextColor: '#212121',
  chatInputAttachmentIcon: 'assets/ic_add_circle.png',
  chatInputAttachmentIconTint: '#9E9E9E',
  chatInputAttachmentBackgroundDrawable: 'assets/ic_circle.png',
  chatInputAttachmentBackgroundColor: '#673AB7',
  chatInputSendIcon: 'assets/ic_send.png',
  chatInputSendIconTint: '#9E9E9E',
  chatInputSendBackgroundDrawable: 'assets/ic_circle.png',
  chatInputSendBackgroundColor: '#673AB7',
  chatInputSeparatorLineColor: '#BDBDBD',
  chatInputSeparatorLineVisible: true,
  chatInputCursorColor: '#9E9E9E',
  shouldHandleKeyboardAppearance: true,
);

