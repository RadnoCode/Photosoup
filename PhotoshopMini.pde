import java.awt.*;

App app;

// ---------- Processing entry ----------

void settings() {
  Rectangle usable = GraphicsEnvironment
    .getLocalGraphicsEnvironment()
    .getMaximumWindowBounds();    // 已扣掉任务栏/停靠栏的“可用区域”（通常是逻辑坐标）
    println(usable.width);
    println(usable.height);
  float ratio = 0.90;             // 你要的占屏比例
  int WinWideth = (int)(usable.width  * ratio);
  int WinHeight = (int)(usable.height * ratio);
  size(WinWideth,WinHeight);
}


void setup() {
  surface.setTitle("Crop Demo - Command startYstem (Single File)");
  app = new App();
}

void draw() {
  background(30);
  //app.update();
  app.render();
}

void mousePressed() {
  app.onMousePressed(mouseX, mouseY, mouseButton);
}
void mouseDragged() {
  app.onMouseDragged(mouseX, mouseY, mouseButton);
}
void mouseReleased() {
  app.onMouseReleased(mouseX, mouseY, mouseButton);
}
void mouseWheel(MouseEvent event) {
  app.onMouseWheel(event.getCount());
}
void keyPressed() {
  app.onKeyPressed(key);
}

// selectInput callback must be global
void fileSelected(File selection) {
  if (app != null) app.ui.onFileSelected(app.doc, selection);
  // when a file is selected, the file will be given to app.doc.
}


