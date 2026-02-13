import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

String _idFromJson(dynamic value) => value?.toString() ?? '';

@JsonSerializable()
class NotificationModel {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  @JsonKey(name: 'readAt')
  final DateTime? readAt;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.read,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}

