part of 'cart_cubit.dart';

@immutable
sealed class CartState {}

final class CartInitial extends CartState {}

final class CartLoading extends CartState {}

final class CartUpdated extends CartState {
  final List<CartItem> items;
  final double totalAmount;
  final int itemCount;

  CartUpdated(this.items, this.totalAmount, this.itemCount);
}

final class CartError extends CartState {
  final String message;

  CartError(this.message);
} 