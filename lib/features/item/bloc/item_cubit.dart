import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/item_repository.dart';

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
}
