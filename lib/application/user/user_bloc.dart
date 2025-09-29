import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/application/var_status.dart';
import 'package:dala_ishchisi/domain/facades/user_facade.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:dala_ishchisi/infrastructure/services/http/http_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'user_bloc.freezed.dart';
part 'user_event.dart';
part 'user_state.dart';

@Injectable()
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserFacade _facade;
  final HttpService _http;

  UserBloc(this._facade, this._http) : super(const UserState.initial()) {
    on<_Users>(_onUsers);
  }

  Future<void> _onUsers(
    _Users event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(usersStatus: VarStatus.loading(), users: []));

    if (event.clearCache) await _http.clearCache();
    final result = await _facade.users(
      event.parentId,
      requiredRemote: event.requiredRemote,
    );

    result.fold(
      (l) => emit(state.copyWith(usersStatus: VarStatus.fail(l))),
      (r) => emit(state.copyWith(usersStatus: VarStatus.success(), users: r)),
    );
  }
}
