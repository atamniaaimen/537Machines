class ListingFilter {
  final String? searchQuery;
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final int? minYear;
  final int? maxYear;
  final String? sortBy;
  final String? locationFilter;

  const ListingFilter({
    this.searchQuery,
    this.category,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.minYear,
    this.maxYear,
    this.sortBy,
    this.locationFilter,
  });

  bool get isEmpty =>
      (searchQuery == null || searchQuery!.isEmpty) &&
      category == null &&
      minPrice == null &&
      maxPrice == null &&
      condition == null &&
      minYear == null &&
      maxYear == null &&
      sortBy == null &&
      (locationFilter == null || locationFilter!.isEmpty);

  ListingFilter copyWith({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? condition,
    int? minYear,
    int? maxYear,
    String? sortBy,
    String? locationFilter,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearCondition = false,
    bool clearMinYear = false,
    bool clearMaxYear = false,
    bool clearSortBy = false,
    bool clearLocation = false,
  }) {
    return ListingFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      category: clearCategory ? null : (category ?? this.category),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      condition: clearCondition ? null : (condition ?? this.condition),
      minYear: clearMinYear ? null : (minYear ?? this.minYear),
      maxYear: clearMaxYear ? null : (maxYear ?? this.maxYear),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      locationFilter:
          clearLocation ? null : (locationFilter ?? this.locationFilter),
    );
  }
}
