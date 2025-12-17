class Layer {
  PImage img = null;
  float opacity = 1.0;
  boolean visible = true;
  String name = "Layer";

  // Transform in CANVAS space
  float x = 0;            // translation
  float y = 0;
  float rotation = 0;     // radians
  float scale = 1.0;      // 

  //Other properties
  float blur,sharp;// need to be initialize

  // Pivot in LOCAL space (image space)
  float pivotX = 0;
  float pivotY = 0;

  Layer(PImage img) {
    this.img = img;
    if (img != null) {
      pivotX = img.width * 0.5;
      pivotY = img.height * 0.5;
    }
  }

  // ---------- Rendering helper ----------
  // Call inside CANVAS space (after doc.view.applyTransform()).
  void applyTransform() {
    translate(x, y);
    translate(pivotX, pivotY);
    rotate(rotation);
    scale(scale);
    translate(-pivotX, -pivotY);
  }

  // ---------- Geometry helpers ----------
  // Pivot position in CANVAS space
  PVector pivotCanvas() {
    return new PVector(x + pivotX, y + pivotY);
  }


}

class LayerStack {
  ArrayList<Layer> list = new ArrayList<Layer>();
  int activeIndex = -1;

  Layer getActive() {
    if (activeIndex < 0 || activeIndex >= list.size()) return null;
    return list.get(activeIndex);//返回下标为activeIndex的那一个
  }

  boolean isEmpty() {
    return list.isEmpty();
  }

  int getActiveIndex() {
    return activeIndex;
  }

  void setActiveIndex(int index) {
    if (list.isEmpty()) {
      activeIndex = -1;
      return;
    }
    int clamped = constrain(index, 0, list.size() - 1);
    activeIndex = clamped;
  }

  void addLayer(Layer layer) {
    if (layer == null) return;
    list.add(layer);
    activeIndex = list.size() - 1;
  }

  void insertLayer(int index, Layer layer) {
    if (layer == null) return;
    int clamped = constrain(index, 0, list.size());
    list.add(clamped, layer);
    activeIndex = clamped;
  }

  void removeLayer(int index) {
    if (index < 0 || index >= list.size()) return;
    list.remove(index);
    if (list.isEmpty()) {
      activeIndex = -1;
    } else if (activeIndex == index) {
      activeIndex = min(index, list.size() - 1);
    } else if (activeIndex > index) {
      activeIndex--;
    }
  }

  void moveLayer(int from, int to) {
    if (from < 0 || from >= list.size()) return;
    int clampedTo = constrain(to, 0, list.size() - 1);
    if (from == clampedTo) return;

    Layer l = list.remove(from);
    list.add(clampedTo, l);
    if (activeIndex == from) {
      activeIndex = clampedTo;
    } else if (activeIndex > from && activeIndex <= clampedTo) {
      activeIndex--;
    } else if (activeIndex < from && activeIndex >= clampedTo) {
      activeIndex++;
    }
  }

  void renameLayer(int index, String newName) {
    if (index < 0 || index >= list.size()) return;
    if (newName == null || newName.trim().isEmpty()) return;
    list.get(index).name = newName.trim();
  }

  void setSingleLayer(Layer layer) {
    list.clear();
    if (layer != null) {
      list.add(layer);
      activeIndex = 0;
    } else {
      activeIndex = -1;
    }
  }
}