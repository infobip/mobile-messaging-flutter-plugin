
class IOSChatSettings {
  final String? title;
  final String? sendButtonColor;
  final String? navigationBarItemsColor;
  final String? navigationBarColor;
  final String? navigationBarTitleColor;

  IOSChatSettings({
      this.title,
      this.sendButtonColor,
      this.navigationBarItemsColor,
      this.navigationBarColor,
      this.navigationBarTitleColor});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sendButtonColor': sendButtonColor,
      'navigationBarItemsColor': navigationBarItemsColor,
      'navigationBarColor': navigationBarColor,
      'navigationBarTitleColor': navigationBarTitleColor,
    };
  }

}