package com.threadlink.orders;

import java.math.BigDecimal;

public class OrderReceipt {
  private final int orderId;
  private final BigDecimal totalAmount;

  public OrderReceipt(int orderId, BigDecimal totalAmount) {
    this.orderId = orderId;
    this.totalAmount = totalAmount;
  }

  public int getOrderId() {
    return orderId;
  }

  public BigDecimal getTotalAmount() {
    return totalAmount;
  }
}
