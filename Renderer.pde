class Renderer{

  Renderer() {
    // 默认构造方法为空，但是避免误认还是补充上了
  }
  
  void drawChecker(Document doc,int w, int h, int s) {
    pushMatrix();
    doc.view.applyTransform();
    noStroke();

    // Tile only inside the cropped canvas region and clip to its bounds.
    int minX = max(0, doc.viewX);
    int minY = max(0, doc.viewY);
    int maxX = min(doc.canvas.width, doc.viewX + w);
    int maxY = min(doc.canvas.height, doc.viewY + h);

    for (int y = minY; y < maxY; y += s) {
      int tileH = min(s, maxY - y);
      for (int x = minX; x < maxX; x += s) {
        int tileW = min(s, maxX - x);
        int v = (((x / s) + (y / s)) % 2 == 0) ? 60 : 80;
        fill(v);
        rect(x, y, tileW, tileH);
      }
    }
    popMatrix();
  }// 棋盘格


  void drawCanvas(Document doc,ToolManager tools){
    if (!doc.renderFlags.dirtyComposite) {
      return;
    }
    PGraphics pg=doc.canvas;
    pg.beginDraw();
    pg.clear();
    pg.stroke(255,0,0);
    pg.clip(doc.viewX, doc.viewY, doc.viewW, doc.viewH);


    for(int i=0;i<doc.layers.list.size();i++){
      Layer l=doc.layers.list.get(i);
      // Skip empty entries and hidden layers. Allow text layers (img can be null).
      if (l == null || !l.visible || (l.img == null && !(l instanceof TextLayer))) {
        continue;
      }
      pg.pushMatrix();

      pg.translate(l.x,l.y);
      pg.translate(l.pivotX,l.pivotY);
      pg.rotate(l.rotation);
      pg.scale(l.scale);
      
      //pg.tint(255,255*l.opacity);
      //pg.image(l.img,-l.pivotX,-l.pivotY);
      //pg.noTint();
      l.drawSelf(doc);
      pg.popMatrix();
      
    }
    pg.noClip();

    pg.endDraw();
    doc.renderFlags.dirtyComposite = false;
  }
  void drawToScreen(Document doc,ToolManager tools){
    pushMatrix();
    doc.view.applyTransform();
    image(doc.canvas,0,0);
    tools.drawOverlay(doc);
    popMatrix();


  }
}


class RenderFlags {
  boolean dirtyComposite = true;
}
