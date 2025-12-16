// Layer.pde
class Layer {
  PImage img = null;
  float opacity = 1.0;
  boolean visible = true;
  String name = "Layer";

  // Transform in CANVAS space
  float x = 0;
  float y = 0;
  float rotation = 0; // radians
  float scale = 1.0;

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

  void applyTransform() {
    translate(x, y);
    translate(pivotX, pivotY);
    rotate(rotation);
    scale(scale);
    translate(-pivotX, -pivotY);
  }

  PVector pivotCanvas() {
    return new PVector(x + pivotX, y + pivotY);
  }
}
