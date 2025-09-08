import 'package:equatable/equatable.dart';

class AiInsight extends Equatable {
  final String message;
  final String? buttonText;
  final String? navigationRoute;
  final dynamic navigationArguments;

  const AiInsight({
    required this.message,
    this.buttonText,
    this.navigationRoute,
    this.navigationArguments,
  });

  @override
  List<Object?> get props => [message, buttonText, navigationRoute, navigationArguments];
}
