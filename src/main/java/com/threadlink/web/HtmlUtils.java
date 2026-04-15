package com.threadlink.web;

public final class HtmlUtils {
  private HtmlUtils() {
  }

  public static String escape(String text) {
    if (text == null) {
      return "";
    }

    return text
      .replace("&", "&amp;")
      .replace("<", "&lt;")
      .replace(">", "&gt;")
      .replace("\"", "&quot;")
  }
}
