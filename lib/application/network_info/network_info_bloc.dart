import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'network_info_bloc.freezed.dart';
part 'network_info_event.dart';
part 'network_info_state.dart';

/// This is to listen connection's status
///
/// Examples:
/// [wrap BlocProvider] and [start listen]
/// ```dart
/// BlocProvider(
///    create: (_) => di<NetworkInfoBloc>()..add(const NetworkInfoEvent.init()),
/// );
/// ```
/// Listen connected to network with BlocListener and [toast status].
/// You can use with BlocBuilder, if you need show in UI.
/// ```dart
/// BlocListener<NetworkInfoBloc, NetworkInfoState>(
///    listenWhen: (old, current) => old.isConnected != current.isConnected,
///    listener: (_, state) {
///      Fluttertoast.showToast(
///        msg: state.isConnected
///            ? Words.hasInternet.str()
///            : Words.noInternet.str(),
///        toastLength: Toast.LENGTH_SHORT,
///        gravity: ToastGravity.BOTTOM,
///        backgroundColor: state.isConnected ? MyColors.green : MyColors.red,
///        textColor: Colors.white,
///        fontSize: 16.0,
///    );
/// }
/// ```
@Injectable()
class NetworkInfoBloc extends Bloc<NetworkInfoEvent, NetworkInfoState> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  NetworkInfoBloc() : super(const NetworkInfoState.initial()) {
    on<_init>(_onInit);
    on<_change>(_onChange);
    on<_forceConnectionCheck>(_onForceConnectionCheck);
  }

  void _onInit(_init event, Emitter<NetworkInfoState> emit) {
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      final isConnected = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);
      add(NetworkInfoEvent.change(isConnected));
    });
  }

  void _onForceConnectionCheck(
      _forceConnectionCheck event, Emitter emit) async {
    emit(NetworkInfoState.initial(
        isConnected: !state.isConnected)); // force update state
    final result = await Connectivity().checkConnectivity();
    final isConnected = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);
    emit(NetworkInfoState.initial(isConnected: isConnected));
  }

  void _onChange(_change event, Emitter<NetworkInfoState> emit) {
    if (state.isConnected != event.isConnected) {
      _showMessage(event.isConnected);
    }
    emit(state.copyWith(isConnected: event.isConnected));
  }

  void _showMessage(bool isConnected) {
    Fluttertoast.showToast(
      msg: isConnected ? Words.hasInternet.str : Words.noInternet.str,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: AppColors.gray.shade9,
      textColor: isConnected ? AppColors.green.shade5 : AppColors.red.shade5,
      fontSize: 16.0,
    );
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
