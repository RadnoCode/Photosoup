public class App {
  Document doc;
  Renderer renderer;
  ToolManager tools;
  CommandManager history;
  UI ui;
  int SelectedColor = color(255, 0, 0, 255);
  /* Five Core Modules
    Doc: The single source of truth for project file data
    Renderer: Retrieves layer information from Doc and renders visual content on the canvas
    ToolManager: Handles tool selection, records the results of sequential operations, and dispatches results to CommandManager
    UI: Manages rendering of basic interface elements and dispatches actionable commands to CommandManager
    CommandManager: Maintains a record of Commands and issues instructions to modify the state of Doc
   */
  App(PApplet parent) {
    this(parent, new Document());
  }

  App(PApplet parent, Document doc) {
    this.doc = doc != null ? doc : new Document();
    renderer = new Renderer();
    tools = new ToolManager();
    history = new CommandManager();
    ui = new UI(parent, this.doc, this);

    // Keep UI widgets in sync after any history change (perform/undo/redo).
    history.setListener(new CommandListener() {
      public void onHistoryChanged(Document d) {
        SwingUtilities.invokeLater(new Runnable() {
          public void run() {
            ui.updatePropertiesFromLayer(d.layers.getActive());
            ui.refreshLayerList(d);
          }
        });
      }
    });

    tools.setTool(new MoveTool()); // When you enter, defualtly choose MoveTool 默认移动工具
  }// Constructor: Initializes the five core modules

  void render() {
    renderer.drawChecker(doc,doc.viewW,doc.viewH,50);
    renderer.drawCanvas(doc, tools);
    renderer.drawToScreen(doc,tools);
    ui.draw(doc, tools, history);
  }//darw concavs and UI

  // ---------- event routing ----------

  //assign mouse and key event, give them to UI first of to Tool.
  void onMousePressed(int mx, int my, int btn) {
    if (ui.handleMousePressed(this, mx, my, btn)) return;
    tools.mousePressed(doc, mx, my, btn);
  }

  void onMouseDragged(int mx, int my, int btn) {
    if (ui.handleMouseDragged(this, mx, my, btn)) return;
    tools.mouseDragged(doc, mx, my, btn);

    // Synchronizes coordinate data to the UI's status display panel
    Layer active = doc.layers.getActive();
    if (active != null) {
      ui.updatePropertiesFromLayer(active);
    }
  }

  void onMouseReleased(int mx, int my, int btn) {
    if (ui.handleMouseReleased(this, mx, my, btn)) return;
    tools.mouseReleased(doc, mx, my, btn);
    ui.refreshLayerList(doc);  // Refreshes the layer list when the mouse is released
  }

  void onMouseWheel(float delta) {
    if (ui.handleMouseWheel(this, delta)) return;
    tools.mouseWheel(doc, delta);
  }

  void onKeyPressed(char k) {
    boolean primary = keyEvent.isControlDown() || keyEvent.isMetaDown();
    boolean shift   = keyEvent.isShiftDown();
    boolean alt     = keyEvent.isAltDown();
    Component focus = KeyboardFocusManager.getCurrentKeyboardFocusManager().getFocusOwner();
    
  //Handle focus

    // When typing in a text field, ignore shortcuts.
    if(focus != null && (focus instanceof JTextComponent)) {
      return;
    }


    if (primary && (k=='z' || k=='Z')) {
      history.undo(doc);
      return;
    }
    if (primary && shift&&(k=='z' || k=='Z')) {
      history.redo(doc);
      return;
    }
    if (k=='o' || k=='O') {
      ui.openFileDialog();
      return;
    }
    if (ui != null && ui.layerListPanel != null && ui.layerListPanel.isFocusInside()) {
      return;
    }
    if (k=='m' || k=='M') {
      tools.setTool(new MoveTool());
      return;      
    }
    if (k=='v' || k=='V') {
    tools.setTool(new LayerMoveTool(history));
    return;
    }
    if (k=='c' || k=='C') {
      tools.setTool(new CropTool(history));
      return;
    }
    if (k=='e' || k=='E') {
      ui.exportCanvas();
      return;
    }
    if (k=='r' || k=='R') {
      tools.setTool(new RotateTool(history));
      return;
    }
  
    if (k=='s' || k=='S') {
        tools.setTool(new ScaleTool(history));
        return;
    }
  }
}