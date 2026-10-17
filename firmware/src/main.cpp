#include <M5Unified.h>

void setup() {
  auto cfg = M5.config();
  M5.begin(cfg);

  M5.Display.setRotation(1);  // 横向き
  M5.Display.fillScreen(TFT_BLACK);
  M5.Display.setTextColor(TFT_WHITE, TFT_BLACK);
  M5.Display.setTextSize(4);
  M5.Display.setCursor(10, 10);
  M5.Display.print("Hello");
}

void loop() {
  M5.update();
  delay(100);
}
