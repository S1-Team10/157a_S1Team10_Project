package com.threadlink.orders;

public class OrderLine {
  private final int itemId;
  private final int quantity;
  private final String selectedSize;
  private final String selectedColor;

  public OrderLine(int itemId, int quantity, String selectedSize, String selectedColor) {
    this.itemId = itemId;
    this.quantity = quantity;
    this.selectedSize = selectedSize;
    this.selectedColor = selectedColor;
  }

  public int getItemId() {
    return itemId;
  }

  public int getQuantity() {
    return quantity;
  }

  public String getSelectedSize() {
    return selectedSize;
  }

  public String getSelectedColor() {
    return selectedColor;
  }
}
