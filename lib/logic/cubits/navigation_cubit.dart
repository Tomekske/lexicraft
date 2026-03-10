import 'package:flutter_bloc/flutter_bloc.dart';

enum AppView { home, practice, listsAndSettings }

class NavigationCubit extends Cubit<AppView> {
  NavigationCubit() : super(AppView.home);

  void setView(AppView view) => emit(view);
}
