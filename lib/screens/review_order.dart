import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kioskflutter/blocs/cart/cart_bloc.dart';
import 'package:kioskflutter/blocs/cart/cart_event.dart';
import 'package:kioskflutter/blocs/cart/cart_state.dart';
import 'package:kioskflutter/blocs/catalog/catalog_bloc.dart';
import 'package:kioskflutter/component/button.dart';
import 'package:kioskflutter/component/image_entity.dart';
import 'package:kioskflutter/component/modifiers.dart';
import 'package:kioskflutter/component/quantity.dart';
import 'package:kioskflutter/constants.dart';
import 'package:kioskflutter/model/cart.dart';
import 'package:kioskflutter/screens/confirmation.dart';

class ReviewOrderContainer extends StatelessWidget {
  const ReviewOrderContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CartBloc bloc = BlocProvider.of<CartBloc>(context);

    return BlocBuilder<CartBloc, CartState>(
      bloc: bloc,
      builder: (ctx, state) => ReviewOrder(
        items: state.items,
      ),
    );
  }
}

class ReviewOrder extends StatelessWidget {
  final List<CartItem> items;

  const ReviewOrder({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    List<Widget> itemsMapped = items
        .map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ReviewItem(
                cartItem: e,
              ),
            ))
        .toList();
    itemsMapped.insert(0, _header(context));
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
              flex: 11,
              child: Container(
                height: double.infinity,
                color: theme.backgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: itemsMapped),
                ),
              )),
          Flexible(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(color: theme.shadowColor,
                    // border: Border(left: BorderSide(color: theme.shadowColor)),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 8,
                          offset: Offset(-2, 0),
                          color: theme.shadowColor,
                          spreadRadius: 0),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Column(
                        children: [_backToMenu(context), const CartSummary()],
                      ),
                    ),
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: BlocBuilder<CartBloc, CartState>(
                                buildWhen: (previous, current) =>
                                    previous.total != current.total,
                                builder: (context, state) => KioskButton(
                                      content: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          const Text(
                                            "PAY",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 4,
                                                fontSize: 20),
                                          ),
                                          Text(
                                            " (\$${state.total.toStringAsFixed(2)})",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                                fontSize: 20),
                                          ),
                                        ],
                                      ),
                                      text:
                                          "PAY (\$${state.total.toStringAsFixed(2)})",
                                      onClicked: () {
                                        showDialog(
                                            barrierDismissible: true,
                                            context: context,
                                            builder: (_) => Container(
                                                  child: Confirmation(),
                                                ));
                                      },
                                    )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        children: [
          Text(
            "REVIEW ORDER",
            style: Theme.of(context)
                .textTheme
                .headline2
                ?.copyWith(letterSpacing: 3),
          ),
          const Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(),
          ))
        ],
      ),
    );
  }

  Widget _backToMenu(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              CupertinoIcons.chevron_back,
              color: kSecondaryTextColor,
              size: 32,
            ),
            Text(
              "BACK TO MENU",
              style: Theme.of(context)
                  .textTheme
                  .headline2
                  ?.copyWith(color: kSecondaryTextColor, letterSpacing: 3),
            )
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    CartBloc cartBloc = BlocProvider.of<CartBloc>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: BlocBuilder<CartBloc, CartState>(
            bloc: cartBloc,
            builder: (context, state) => Column(
                  children: [
                    _summaryList(context, "SUB TOTAL",
                        "\$${state.subTotal.toStringAsFixed(2)}"),
                    _summaryList(
                        context, "TAX", "\$${state.tax.toStringAsFixed(2)}"),
                    _summaryList(context, "SERVICE CHARGE",
                        "\$${state.serviceCharge.toStringAsFixed(2)}")
                  ],
                )),
      ),
    );
  }

  Widget _summaryList(BuildContext context, String line, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            line,
            style: Theme.of(context).textTheme.headline5?.copyWith(
                fontWeight: FontWeight.normal, color: kSecondaryTextColor),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final CartItem cartItem;

  const ReviewItem({Key? key, required this.cartItem}) : super(key: key);

  void _onAddOnRemoved(String id) {}

  @override
  Widget build(BuildContext context) {
    bool hasAddOns = cartItem.addOns.isNotEmpty;
    List<Widget> children = [];
    if (hasAddOns) {
      for (var records in cartItem.addOns.values) {
        for (var rec in records) {
          children.add(AddOnChip(
              addOnName: rec.addOnRef.name,
              id: rec.addOnRef.id,
              onRemoved: _onAddOnRemoved));
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _triggerCartItemEdit(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 120,
                color: Colors.tealAccent,
                child: ItemImage(
                  imageUrl: cartItem.itemRef.imageUrl,
                  width: 120,
                  height: 120,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasAddOns) ...[_buildItemName(context)],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _triggerCartItemEdit(context);
                        },
                        child: Container(
                          width: 120,
                          child: hasAddOns
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: children,
                                )
                              : _buildItemName(context),
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      child: Quantity(
                        qty: cartItem.quantity,
                        onDecrease: () {
                          context.read<CartBloc>().itemQuantityChanged(
                              CartItemQuantityChangeEvent(cartItem.itemRef, 1,
                                  QuantityChangeType.decrement));
                        },
                        onIncrease: () {
                          context.read<CartBloc>().itemQuantityChanged(
                              CartItemQuantityChangeEvent(cartItem.itemRef, 1,
                                  QuantityChangeType.increment));
                        },
                      ),
                    ),
                    Container(
                      height: 100,
                      constraints: const BoxConstraints(minWidth: 120),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PriceLabel(
                          price: cartItem.getItemSubTotal(),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<CartBloc>().itemModifiedEvent(
                            CartItemModificationEvent.fromCartItem(
                                cartItem, CartItemModificationType.removed));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(CupertinoIcons.delete_left_fill,
                            size: 32, color: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _triggerCartItemEdit(BuildContext context) {
    context.read<CatalogBloc>().selectActiveCartItem(cartItem);
    Navigator.pushNamed(context, "/item");
  }

  Widget _buildItemName(context) {
    return GestureDetector(
      onTap: () {
        _triggerCartItemEdit(context);
      },
      child: Text(
        cartItem.itemRef.name.toUpperCase(),
        style: Theme.of(context).textTheme.headline4,
      ),
    );
  }
}