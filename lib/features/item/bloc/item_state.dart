import 'package:unifind/core/models/user_model.dart';
import 'package:unifind/features/item/data/models/item_model.dart';

abstract class ItemState {}

class ItemInitial extends ItemState {} // Initial state

class ItemLoading extends ItemState {} // Loading state

class ItemSuccess extends ItemState {} // When update succeeds

// For loading a list of items
class ItemsLoaded extends ItemState {
  final List<Item> items;
  ItemsLoaded(this.items);
}

// For loading a single item
class ItemLoaded extends ItemState {
  final Item item;
  ItemLoaded(this.item);
}

class ItemPictureUpdated extends ItemState {
  final String imageUrl;
  ItemPictureUpdated(this.imageUrl);
}

class ItemError extends ItemState {
  // On error
  final String message;

  ItemError(this.message);
}
