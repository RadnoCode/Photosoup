// App.pde
class App {
  Document doc;
  Renderer renderer;
  ToolManager tools;
  CommandManager history;
  UI ui;

  App() {
    doc = new Document();
    renderer = new Renderer();
    tools = new ToolManager();
    history = new CommandManager();
    ui = new UI();

    tools.setTool(new MoveTool()); // default tool
  }

  void render() {
    renderer.draw(doc, tools);
    ui.draw(doc, tools, history);
  }

  // ---------- event routing ----------
  void onMousePressed(int mx, int my, int btn) {
    if (ui.handleMousePressed(this, mx, my, btn)) return;
    tools.mousePressed(doc, mx, my, btn);
  }

  void onMouseDragged(int mx, int my, int btn) {
    if (ui.handleMouseDragged(this, mx, my, btn)) return;
    tools.mouseDragged(doc, mx, my, btn);
  }

  void onMouseReleased(int mx, int my, int btn) {
    if (ui.handleMouseReleased(this, mx, my, btn)) return;
    tools.mouseReleased(doc, mx, my, btn);
  }

  void onMouseWheel(float delta) {
    if (ui.handleMouseWheel(this, delta)) return;
    tools.mouseWheel(doc, delta);
  }

  void onKeyPressed(char k) {
    boolean ctrl = (keyEvent.isMetaDown() || keyEvent.isControlDown());

    if (ctrl && (k=='z' || k=='Z')) {
      history.undo(doc);
      return;
    }
    if (ctrl && (k=='y' || k=='Y')) {
      history.redo(doc);
      return;
    }

    if (k=='o' || k=='O') {
      ui.openFileDialog();
      return;
    }
    if (k=='m' || k=='M') {
      tools.setTool(new MoveTool());
      return;
    }
    if (k=='c' || k=='C') {
      tools.setTool(new CropTool(history));
      return;
    }
    if (k=='r' || k=='R') {
      tools.setTool(new RotateTool(history));
      return;
    }
  }
}
