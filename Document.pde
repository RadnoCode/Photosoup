public class Document {
  PGraphics canvas = createGraphics(2000, 2000);
  ViewState view = new ViewState();
  LayerStack layers = new LayerStack();
  RenderFlags renderFlags = new RenderFlags();
  
  
  void markChanged(){
    renderFlags.dirtyComposite = true;
  }
  Document() {
    // start with an empty doc (no layers yet)
  }
}

class CanvasSpec {// Canvas Statement
  int width, height;
  CanvasSpec(int w, int h) {
    this.width = w;
    this.height = h;
  }
}