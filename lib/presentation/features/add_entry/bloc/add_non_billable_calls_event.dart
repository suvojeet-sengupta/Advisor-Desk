import 'package:equatable/equatable.dart';

abstract class AddNonBillableCallsEvent extends Equatable {
  const AddNonBillableCallsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNonBillableCalls extends AddNonBillableCallsEvent {
  const InitializeNonBillableCalls();
}



class NonBillableCallsValuechanged extends AddNonBillableCallsEvent {
  final int nonBillableCalls;

  const NonBillableCallsValuechanged({required this.nonBillableCalls});

  @override
  List<Object> get props => [nonBillableCalls];
}

class SubmitNonBillableCalls extends AddNonBillableCallsEvent {
  const SubmitNonBillableCalls();
}
