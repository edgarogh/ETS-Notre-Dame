class ETSNotificationData {
  String typeNotification;
  String sigle;
  String element;
  String note;

  ETSNotificationData(
      {this.typeNotification, this.sigle, this.element, this.note});

  ETSNotificationData.fromJson(Map<String, dynamic> json) {
    typeNotification = json['TypeNotification'] as String;
    sigle = json['Sigle'] as String;
    element = json['Element'] as String;
    note = json['Note'] as String;
  }
}
