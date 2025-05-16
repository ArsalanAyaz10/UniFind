import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/item_repository.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

class ItemCubit extends Cubit<ItemState> {
  final ItemRepository itemRepository;

  ItemCubit(this.itemRepository) : super(ItemInitial());

  Future<void> addItem({
    required String name,
    required String description,
    required String campus,
    required String specificLocation,
    required String category,
    required DateTime date,
    required TimeOfDay time,
    required File imageFile,
  }) async {
    emit(ItemLoading());

    try {
      await itemRepository.addItem(
        name: name,
        description: description,
        campus: campus,
        specificLocation: specificLocation,
        category: category,
        date: date,
        time: time,
        imageFile: imageFile,
      );
      emit(ItemSuccess());
    } catch (e) {
      emit(ItemError(e.toString()));
    }
  }

  Future<void> fetchItems() async {
    emit(ItemLoading());

    try {
      final List<Item> items = await itemRepository.fetchItems();
      emit(ItemsLoaded(items));
    } catch (e) {
      emit(ItemError('Failed to load items: ${e.toString()}'));
    }
  }

  Future<void> fetchItemById(String id) async {
    emit(ItemLoading());

    try {
      final Item item = await itemRepository.getItemById(id);
      emit(ItemLoaded(item));
    } catch (e) {
      emit(ItemError('Failed to fetch item: ${e.toString()}'));
    }
  }

Future<void> updateItemStatus(String itemId, String status) async {
  emit(ItemLoading());

  try {
    await itemRepository.updateItemStatus(itemId, status);

    // Refetch the list after updating
    final List<Item> items = await itemRepository.fetchItems();
    emit(ItemsLoaded(items));
  } catch (e) {
    emit(ItemError('Failed to update status: ${e.toString()}'));
  }
}

}
