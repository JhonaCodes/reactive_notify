import 'dart:developer';

import 'package:reactive_notify/src/handler/async_state.dart';

import 'notifier_impl.dart';
import 'repository_impl.dart';

/// Viewmodel async initialization  wit AsyncState Config.
abstract class ViewmodelAsyncImpl<T> extends NotifierImpl<AsyncState<T>>{

  final RepositoryImpl _repository;

  ViewmodelAsyncImpl(this._repository,super.value){
    _initialization();
  }

  Future<T> init();


  bool _initialized = false;
  Future<void> _initialization() async {

    if(!_initialized){

      log('ViewmodelAsyncI.asyncInit');

      await init();

      _initialized = true;
    }

  }

}
