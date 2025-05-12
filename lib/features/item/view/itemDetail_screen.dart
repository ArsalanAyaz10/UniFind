import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unifind/features/auth/bloc/auth_cubit.dart';
import 'package:unifind/features/item/bloc/item_cubit.dart';
import 'package:unifind/features/item/bloc/item_state.dart';
import 'package:unifind/features/item/data/models/item_model.dart';
import 'package:unifind/features/item/view/widgets/imageClipper.dart';
import 'package:unifind/features/profile/bloc/profile_cubit.dart';
import 'package:unifind/features/profile/bloc/profile_state.dart';

class ItemdetailScreen extends StatefulWidget {
  final String itemId; // <-- Pass this when navigating

  const ItemdetailScreen({super.key, required this.itemId, required Item item});

  @override
  State<ItemdetailScreen> createState() => _ItemdetailScreenState();
}

class _ItemdetailScreenState extends State<ItemdetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ItemCubit>().fetchItemById(
      widget.itemId,
    ); // You should define this in your cubit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE96443),
                Color(0xFFED6B47),
                Color(0xFFF0724B),
                Color(0xFFF37A4F),
                Color(0xFFF68152),
                Color(0xFFF99856),
                Color(0xFFF9B456),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: BlocBuilder<ItemCubit, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ItemLoaded) {
            final item = state.item;
            return ItemUI(item: item);
          } else if (state is ItemError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text("No item found."));
          }
        },
      ),
    );
  }
}

class ItemUI extends StatefulWidget {
  final Item item; // replace with your actual model class

  const ItemUI({super.key, required this.item});

  @override
  State<ItemUI> createState() => _ItemUIState();
}

class _ItemUIState extends State<ItemUI> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isAdded ? Colors.red : Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isAdded ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  onTap: () {
                    setState(() => _isAdded = !_isAdded);
                  },
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // Text(
            //   "Posted by: ${item.postedBy}",
            //   style: const TextStyle(fontSize: 16),
            // ),
            const SizedBox(height: 10),
            Text(
              item.description ?? 'No description provided.',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(thickness: 1, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  item.category,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  item.status,
                  style: TextStyle(
                    fontSize: 16,
                    color: item.status == "Lost" ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
