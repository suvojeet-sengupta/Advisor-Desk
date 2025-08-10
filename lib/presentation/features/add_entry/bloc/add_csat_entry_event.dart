import 'package:equatable/equatable.dart';
import 'package:advisor_desk/domain/entities/csat_entry.dart';

abstract class AddCSATEntryEvent extends Equatable {
  const AddCSATEntryEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCSATEntry extends AddCSATEntryEvent {
  final DateTime? date;
  final CSATEntry? entry;

  const InitializeCSATEntry({this.date, this.entry});

  @override
  List<Object?> get props => [date, entry];
}

class CSATDateChanged extends AddCSATEntryEvent {
  final DateTime date;

  const CSATDateChanged({required this.date});

  @override
  List<Object> get props => [date];
}

class T2CountChanged extends AddCSATEntryEvent {
  final int count;

  const T2CountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

class B2CountChanged extends AddCSATEntryEvent {
  final int count;

  const B2CountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

class NCountChanged extends AddCSATEntryEvent {
  final int count;

  const NCountChanged({required this.count});

  @override
  List<Object> get props => [count];
}

class SubmitCSATEntry extends AddCSATEntryEvent {
  const SubmitCSATEntry();
}

class DeleteCSATEntry extends AddCSATEntryEvent {
  const DeleteCSATEntry();
}
