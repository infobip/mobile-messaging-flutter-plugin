library chat_customization;
import 'package:infobip_mobilemessaging/models/configuration.dart' as mmconfiguration;

Object customTheme = mmconfiguration.InAppChatCustomization(
   //toolbar
   toolbarTitle: 'Chat',
   toolbarTitleColor: '#FFFFFF',
   toolbarTintColor: '#FF33F3',
   toolbarBackgroundColor: '#673AB7',
   //chat
   widgetTheme: 'dark',
   chatBackgroundColor: '#D1C4E9',
   noConnectionAlertTextColor: '#FFFFFF',
   noConnectionAlertBackgroundColor: '#212121',
   //input
   chatInputSeparatorVisible: true,
   attachmentButtonIcon: 'assets/ic_add_circle.png',
   sendButtonIcon: 'assets/ic_send.png',
   sendButtonTintColor: '#9E9E9E',
   chatInputPlaceholderColor: '#757575',
   chatInputCursorColor: '#9E9E9E',
   chatInputBackgroundColor: '#D1C4E9',
   android: mmconfiguration.AndroidInAppChatCustomization(
       //status bar
       chatStatusBarColorLight: true,
       chatStatusBarBackgroundColor: '#673AB7',
       //toolbar
       chatNavigationIcon: 'assets/ic_back.png',
       chatNavigationIconTint: '#FFFFFF',
       chatSubtitleText: '#1',
       chatSubtitleTextColor: '#FFFFFF',
       chatSubtitleTextAppearanceRes: 'TextAppearance_AppCompat_Subtitle',
       chatSubtitleCentered: true,
       chatTitleTextAppearanceRes: 'TextAppearance_AppCompat_Title',
       chatTitleCentered: true,
       chatMenuItemsIconTint: '#FFFFFF',
       chatMenuItemSaveAttachmentIcon: 'assets/ic_download.png',
       //chat
       chatProgressBarColor: '#9E9E9E',
       chatNetworkConnectionErrorText: 'Offline',
       chatNetworkConnectionErrorTextAppearanceRes: 'TextAppearance_AppCompat_Small',
       //input
       chatInputSeparatorLineColor: '#BDBDBD',
       chatInputHintText: 'Message',
       chatInputTextColor: '#212121',
       chatInputTextAppearance: 'TextAppearance_AppCompat',
       chatInputAttachmentIconTint: '#9E9E9E',
       chatInputAttachmentBackgroundColor: '#673AB7',
       chatInputAttachmentBackgroundDrawable: 'assets/ic_circle.png',
       chatInputSendIconTint: '#9E9E9E',
       chatInputSendBackgroundColor: '#673AB7',
       chatInputSendBackgroundDrawable: 'assets/ic_circle.png',
   ),
   ios: mmconfiguration.IOSInAppChatCustomization(initialHeight: 50)
);