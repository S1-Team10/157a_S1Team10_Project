package com.threadlink.web;

public final class JsonUtils {
  private JsonUtils() {
  }

  public static String escape(String text) {
    if (text == null) {
      return "";
    }

    return text
      .replace("\\", "\\\\")
      .replace("\"", "\\\"")
      .replace("\b", "\\b")
      .replace("\f", "\\f")
      .replace("\n", "\\n")
      .replace("\r", "\\r")
      .replace("\t", "\\t");
  }
}
