package com.threadlink.catalog;

import java.math.BigDecimal;

public class Item {
  private final int itemId;
  private final String itemName;
  private final String description;
  private final BigDecimal price;
  private final int minStock;
  private final int maxStock;

  public Item(int itemId, String itemName, String description, BigDecimal price, int minStock, int maxStock) {
    this.itemId = itemId;
    this.itemName = itemName;
    this.description = description;
    this.price = price;
    this.minStock = minStock;
    this.maxStock = maxStock;
  }

  public int getItemId() {
    return itemId;
  }

  public String getItemName() {
    return itemName;
  }

  public String getDescription() {
    return description;
  }

  public BigDecimal getPrice() {
    return price;
  }

  public int getMinStock() {
    return minStock;
  }

  public int getMaxStock() {
    return maxStock;
  }
}
