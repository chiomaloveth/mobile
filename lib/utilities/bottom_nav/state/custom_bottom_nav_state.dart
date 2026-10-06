class CustomBottomNavState {
  final int pageIndex;

  const CustomBottomNavState({this.pageIndex = 0});

  CustomBottomNavState copyWith({int? pageIndex}) {
    return CustomBottomNavState(
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }
}
