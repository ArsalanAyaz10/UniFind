import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/item_repository.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

class FakeItemRepository implements ItemRepository {
  bool shouldThrow = false;

  @override
  Future<void> addItem({
    required String name,
    required String description,
    required String campus,
    required String specificLocation,
    required String category,
    required DateTime date,
    required TimeOfDay time,
    File? imageFile,
  }) async {
    if (shouldThrow) throw Exception('Add failed');
  }

  @override
  Future<List<Item>> fetchItems() async {
    if (shouldThrow) throw Exception('Fetch failed');
    return [fakeItem];
  }

  @override
  Future<Item> getItemById(String id) async {
    if (shouldThrow) throw Exception('Get by ID failed');
    return fakeItem;
  }

  @override
  Future<void> updateItemStatus(String itemId, String status) async {
    if (shouldThrow) throw Exception('Update failed');
  }

  @override
  // TODO: implement firebaseAuth
  FirebaseAuth get firebaseAuth => throw UnimplementedError();

  @override
  // TODO: implement firestore
  FirebaseFirestore get firestore => throw UnimplementedError();
}

final fakeItem = Item(
  id: '1',
  name: 'Lost Phone',
  description: 'iPhone found near library',
  campus: 'North Campus',
  specificLocation: 'Library Entrance',
  category: 'Electronics',
  date: DateTime.now(),
  time: const TimeOfDay(hour: 10, minute: 30),
  imageUrl: null,
  status: 'Lost',
);

void main() {
  late FakeItemRepository fakeRepository;
  late ItemCubit itemCubit;

  setUp(() {
    fakeRepository = FakeItemRepository();
    itemCubit = ItemCubit(fakeRepository);
  });

  tearDown(() {
    itemCubit.close();
  });

  group('ItemCubit Tests Without mockito', () {
    blocTest<ItemCubit, ItemState>(
      'emits [ItemLoading, ItemSuccess] when addItem succeeds',
      build: () => itemCubit,
      act: (cubit) => cubit.addItem(
        name: fakeItem.name,
        description: fakeItem.description,
        campus: fakeItem.campus,
        specificLocation: fakeItem.specificLocation,
        category: fakeItem.category,
        date: fakeItem.date,
        time: fakeItem.time,
      ),
      expect: () => [ItemLoading(), ItemSuccess()],
    );

    blocTest<ItemCubit, ItemState>(
      'emits [ItemLoading, ItemsLoaded] when fetchItems succeeds',
      build: () => itemCubit,
      act: (cubit) => cubit.fetchItems(),
      expect: () => [ItemLoading(), ItemsLoaded([fakeItem])],
    );

    blocTest<ItemCubit, ItemState>(
      'emits [ItemLoading, ItemLoaded] when fetchItemById succeeds',
      build: () => itemCubit,
      act: (cubit) => cubit.fetchItemById('1'),
      expect: () => [ItemLoading(), ItemLoaded(fakeItem)],
    );

    blocTest<ItemCubit, ItemState>(
      'emits [ItemLoading, ItemsLoaded] when updateItemStatus succeeds',
      build: () => itemCubit,
      act: (cubit) => cubit.updateItemStatus('1', 'Found'),
      expect: () => [ItemLoading(), ItemsLoaded([fakeItem])],
    );

    blocTest<ItemCubit, ItemState>(
      'emits [ItemLoading, ItemError] when addItem throws error',
      build: () {
        fakeRepository.shouldThrow = true;
        return ItemCubit(fakeRepository);
      },
      act: (cubit) => cubit.addItem(
        name: fakeItem.name,
        description: fakeItem.description,
        campus: fakeItem.campus,
        specificLocation: fakeItem.specificLocation,
        category: fakeItem.category,
        date: fakeItem.date,
        time: fakeItem.time,
      ),
      expect: () => [
        ItemLoading(),
        isA<ItemError>().having((e) => e.message, 'message', contains('Add failed')),
      ],
    );
  });
}
