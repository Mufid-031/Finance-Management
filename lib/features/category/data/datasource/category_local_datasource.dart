import 'package:finance_management/features/category/data/dto/category_dto.dart';

class CategoryLocalDatasource {
  final List<CategoryDTO> _storage = [];

  Future<List<CategoryDTO>> getAll() async => _storage;

  Future<void> create(CategoryDTO dto) async {
    _storage.add(dto);
  }

  Future<void> update(CategoryDTO dto) async {
    final index = _storage.indexWhere((category) => category.id == dto.id);
    if (index != -1) {
      _storage[index] = dto;
    }
  }

  Future<void> delete(String id) async {
    _storage.removeWhere((category) => category.id == id);
  }
}
