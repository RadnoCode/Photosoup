// Document.pde
class Document {
  CanvasSpec canvas = new CanvasSpec(900, 600);
  ViewState view = new ViewState();

  LayerStack layers = new LayerStack();
  RenderFlags renderFlags = new RenderFlags();

  Document() {
    // starts empty
  }
}

class CanvasSpec {
  int w, h;
  CanvasSpec(int w, int h) {
    this.w = w;
    this.h = h;
  }
}

class ViewState {
  float zoom = 1.0;
  float panX = 80;
  float panY = 50;

  void applyTransform() {
    translate(panX, panY);
    scale(zoom);
  }

  public float screenToCanvasX(float mx) {
    return (mx - panX) / zoom;
  }
  public float screenToCanvasY(float my) {
    return (my - panY) / zoom;
  }

  public float canvasToScreenX(float cx) { 
    return panX + cx * zoom; 
  }
  public float canvasToScreenY(float cy) { 
    return panY + cy * zoom; 
  }

  void zoomAroundMouse(float delta) {
    float oldZoom = zoom;
    float factor = pow(1.10, -delta);
    zoom = constrain(oldZoom * factor, 0.1, 12.0);

    float mx = mouseX, my = mouseY;
    float beforeX = (mx - panX) / oldZoom;
    float beforeY = (my - panY) / oldZoom;
    panX = mx - beforeX * zoom;
    panY = my - beforeY * zoom;
  }
}

class LayerStack {
  ArrayList<Layer> list = new ArrayList<Layer>();
  int activeIndex = -1;

  Layer getActive() {
    if (activeIndex < 0 || activeIndex >= list.size()) return null;
    return list.get(activeIndex);
  }

  void setSingleLayer(Layer layer) {
    list.clear();
    list.add(layer);
    activeIndex = 0;
  }
}
