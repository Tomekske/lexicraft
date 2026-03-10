import 'package:flutter_bloc/flutter_bloc.dart';

enum AppView { practice, listsAndSettings }

class NavigationCubit extends Cubit<AppView> {
  NavigationCubit() : super(AppView.practice);

  void setView(AppView view) => emit(view);
}
