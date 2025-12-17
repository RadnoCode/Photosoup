class Renderer {
  
  void drawChecker(int w, int h, int s) {
    noStroke();
    for (int y = 0; y+s <= h; y += s) {
      for (int x = 0; x+s <= w; x += s) {
        int v = ((x/s + y/s) % 2 == 0) ? 60 : 80;
        fill(v);
        rect(x, y, s, s);
      }
    }
  }// 棋盘格
  
  void draw(Document doc, ToolManager tools) {
    pushMatrix();
    doc.view.applyTransform();

    drawChecker(doc.canvas.w, doc.canvas.h, 20);

    // draw all visible layers in stack order so the Swing list matches canvas order
    for (int i = 0; i < doc.layers.list.size(); i++) {
      Layer layer = doc.layers.list.get(i);
      if (layer == null || layer.img == null || !layer.visible) continue;

      pushMatrix();
      layer.applyTransform();
      tint(255, 255 * layer.opacity);
      image(layer.img, 0, 0);
      noTint();
      popMatrix();
    }

    // gently highlight the active layer to give feedback in canvas space
    Layer active = doc.layers.getActive();
    if (active != null && active.img != null && active.visible) {
      stroke(255, 200, 80, 180);
      noFill();
      pushMatrix();
      active.applyTransform();
      rect(0, 0, active.img.width, active.img.height);
      popMatrix();
    }

    // canvas border
    noFill();
    stroke(200);
    rect(0, 0, doc.canvas.w, doc.canvas.h);

    // tool overlay in canvas coords
    tools.drawOverlay(doc);

    popMatrix();

    // tiny hint
    fill(200);
    textSize(12);
    text("Shortcuts: O Open | M Move | C Crop | Ctrl/Cmd+Z Undo | Ctrl/Cmd+Y Redo", 12, height - 12);
  }


}
class RenderFlags {
  boolean dirtyComposite = true;
}