import 'package:json_annotation/json_annotation.dart';

part 'sync_dto.g.dart';

/// DTO dla manifestu synchronizacji (bootstrap)
@JsonSerializable()
class SyncManifestDto {
  final Map<String, SyncModuleInfoDto> modules;
  final DateTime serverTime;

  SyncManifestDto({
    required this.modules,
    required this.serverTime,
  });

  factory SyncManifestDto.fromJson(Map<String, dynamic> json) => 
      _$SyncManifestDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$SyncManifestDtoToJson(this);
}

/// DTO dla informacji o module synchronizacji
@JsonSerializable()
class SyncModuleInfoDto {
  final int totalCount;
  final int totalPages;
  final int pageSize;

  SyncModuleInfoDto({
    required this.totalCount,
    required this.totalPages,
    required this.pageSize,
  });

  factory SyncModuleInfoDto.fromJson(Map<String, dynamic> json) => 
      _$SyncModuleInfoDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$SyncModuleInfoDtoToJson(this);
}

/// DTO dla odpowiedzi paginowanej
@JsonSerializable()
class PaginatedResponseDto<T> {
  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  PaginatedResponseDto({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final itemsJson = json['items'] as List<dynamic>;
    return PaginatedResponseDto(
      items: itemsJson.map((item) => fromJsonT(item)).toList(),
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      totalCount: json['totalCount'] as int,
      totalPages: json['totalPages'] as int,
      hasPreviousPage: json['hasPreviousPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }
  
  Map<String, dynamic> toJson(T Function(T) toJsonT) => {
    'items': items.map(toJsonT).toList(),
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'totalCount': totalCount,
    'totalPages': totalPages,
    'hasPreviousPage': hasPreviousPage,
    'hasNextPage': hasNextPage,
  };
}

/// DTO dla słowników systemowych
@JsonSerializable()
class SystemDictionariesDto {
  final List<AllergenDictionaryItemDto> allergens;
  final List<DishCategoryDictionaryItemDto> dishCategories;
  final List<StatusDictionaryItemDto> banStatuses;
  final List<StatusDictionaryItemDto> reportStatuses;
  final List<StatusDictionaryItemDto> orderStatuses;
  final List<StatusDictionaryItemDto> orderItemStatuses;
  final List<StatusDictionaryItemDto> reservationStatuses;
  final List<StatusDictionaryItemDto> tableStatuses;

  SystemDictionariesDto({
    required this.allergens,
    required this.dishCategories,
    required this.banStatuses,
    required this.reportStatuses,
    required this.orderStatuses,
    required this.orderItemStatuses,
    required this.reservationStatuses,
    required this.tableStatuses,
  });

  factory SystemDictionariesDto.fromJson(Map<String, dynamic> json) => 
      _$SystemDictionariesDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$SystemDictionariesDtoToJson(this);
}

/// DTO dla elementu słownika alergenów
@JsonSerializable()
class AllergenDictionaryItemDto {
  final String token;
  final String namePl;
  final String nameEn;
  final String? shortName;
  final String colorCode;

  AllergenDictionaryItemDto({
    required this.token,
    required this.namePl,
    required this.nameEn,
    this.shortName,
    this.colorCode,
  });

  factory AllergenDictionaryItemDto.fromJson(Map<String, dynamic> json) => 
      _$AllergenDictionaryItemDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$AllergenDictionaryItemDtoToJson(this);
}

/// DTO dla elementu słownika kategorii dań
@JsonSerializable()
class DishCategoryDictionaryItemDto {
  final String token;
  final String namePl;
  final String nameEn;
  final int? sortOrder;

  DishCategoryDictionaryItemDto({
    required this.token,
    required this.namePl,
    required this.nameEn,
    this.sortOrder,
  });

  factory DishCategoryDictionaryItemDto.fromJson(Map<String, dynamic> json) => 
      _$DishCategoryDictionaryItemDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$DishCategoryDictionaryItemDtoToJson(this);
}

/// DTO dla elementu słownika statusów
@JsonSerializable()
class StatusDictionaryItemDto {
  final String token;
  final String namePl;
  final String nameEn;
  final String colorCode;
  final int sortOrder;

  StatusDictionaryItemDto({
    required this.token,
    required this.namePl,
    required this.nameEn,
    required this.colorCode,
    required this.sortOrder,
  });

  factory StatusDictionaryItemDto.fromJson(Map<String, dynamic> json) => 
      _$StatusDictionaryItemDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$StatusDictionaryItemDtoToJson(this);
}
