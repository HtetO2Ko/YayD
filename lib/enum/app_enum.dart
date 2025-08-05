enum FilterDateEnum {
  today("Today", 0),
  yesterday("Yesterday", 1),
  custom("Custom", 2),
  all("All", 3),
  month("Monthly", 4);

  final String name;
  final int value;

  const FilterDateEnum(this.name, this.value);
}
