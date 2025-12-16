// Main.pde
App app;

int winW;
int winH;

void setup() {
  winW = int(displayWidth);
  winH = int(displayHeight);
  println(winW);
  println(winH);
  size(1536,864);
  pixelDensity(displayDensity());
  surface.setTitle("Crop Demo - Command System (Multi-file)");
  //size(winW,winH,P2D);   //这张代码有问题，不知道为何。
  app = new App();
}

void draw() {
  background(30);
  app.render();
}

// 事件转发...
void mousePressed()  { app.onMousePressed(mouseX, mouseY, mouseButton); }
void mouseDragged()  { app.onMouseDragged(mouseX, mouseY, mouseButton); }
void mouseReleased() { app.onMouseReleased(mouseX, mouseY, mouseButton); }
void mouseWheel(MouseEvent event) { app.onMouseWheel(event.getCount()); }
void keyPressed() { app.onKeyPressed(key); }

// selectInput callback must be global
void fileSelected(File selection) {
  if (app != null) app.ui.onFileSelected(app.doc, selection);
}
