import 'package:equatable/equatable.dart';

class AiInsight extends Equatable {
  final String id;
  final String message;
  final String? buttonText;
  final String? navigationRoute;
  final dynamic navigationArguments;

  final bool isUser;

  AiInsight({
    String? id,
    required this.message,
    this.buttonText,
    this.navigationRoute,
    this.navigationArguments,
    this.isUser = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  @override
  List<Object?> get props => [id, message, buttonText, navigationRoute, navigationArguments, isUser];
}