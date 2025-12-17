import javax.swing.*;
import javax.swing.event.*;
import java.awt.datatransfer.*;
import java.awt.event.*;
import processing.awt.PSurfaceAWT;

class UI {

  int RightpanelW = 200;
  int RightpanelX =width-RightpanelW;
  int LeftPannelW=64;


  UIButton btnOpen, btnAddLayer, btnDeleteLayer, btnMove, btnCrop, btnUndo, btnRedo;

  // Swing components embedded inside the Processing frame so beginners can see how
  // Processing and Swing can cooperate.
  JList<String> layerList;
  DefaultListModel<String> layerModel;
  JScrollPane layerScroll;
  JPanel swingOverlay;

  Document document;
  CommandManager history;

  UI(Document document, CommandManager history) {
    this.document = document;
    this.history = history;
    int x = RightpanelX + 12;
    int y = 20;
    int w = RightpanelW - 24;
    int h = 28;
    int gap = 10;

    btnOpen = new UIButton(x, y, w, h, "Open (O)");
    y += h + gap;
    btnAddLayer = new UIButton(x, y, w, h, "New Layer");
    y += h + gap;
    btnDeleteLayer = new UIButton(x, y, w, h, "Delete Layer");
    y += h + gap;
    btnMove = new UIButton(x, y, w, h, "Move (M)");
    y += h + gap;
    btnCrop = new UIButton(x, y, w, h, "Crop (C)");
    y += h + gap;
    btnUndo = new UIButton(x, y, w, h, "Undo");
    y += h + gap;
    btnRedo = new UIButton(x, y, w, h, "Redo");
    y += h + gap;

    setupLayerPanel();
  }

  void draw(Document doc, ToolManager tools, CommandManager history) {
    RightpanelX = width - RightpanelW;
    // panel background
    noStroke();
    fill(45);
    rect(RightpanelX, 0, RightpanelW, height);
    rect(0,0,LeftPannelW,height);

    updateSwingPanelBounds();
    refreshLayerList(doc);

    // buttons
    btnOpen.draw(false);
    btnAddLayer.draw(false);
    btnDeleteLayer.draw(false);
    btnMove.draw("Move".equals(tools.activeName()));
    btnCrop.draw("Crop".equals(tools.activeName()));
    btnUndo.draw(false);
    btnRedo.draw(false);

    // status
    fill(230);
    textSize(12);
    text("Active Tool: " + tools.activeName(), RightpanelX + 12, height - 70);
    text("X-axis: " + /*history.undoCount()*/mouseX, RightpanelX + 12, height - 50);
    text("Y-axis: " + /*history.redoCount()*/mouseY, RightpanelX + 12, height - 30);

    if (doc.layers.getActive() == null || doc.layers.getActive().img == null) {
      fill(255, 160, 160);
      text("No image loaded.", RightpanelX + 12, height - 95);
    } else {
      fill(180);
      Layer a = doc.layers.getActive();
      text("Image: " + a.img.width + "x" + a.img.height, RightpanelX + 12, height - 95);
      text("Active Layer: " + a.name, RightpanelX + 12, height - 115);
    }
  }

  boolean handleMousePressed(App app, int mx, int my, int btn) {
    if (mx < RightpanelX) return false;

    // buttons (generate intents)
    if (btnOpen.hit(mx, my)) {
      openFileDialog();
      return true;
    }
    if (btnAddLayer.hit(mx, my)) {
      createBlankLayer(app.doc);
      return true;
    }
    if (btnDeleteLayer.hit(mx, my)) {
      deleteActiveLayer(app.doc);
      return true;
    }
    if (btnMove.hit(mx, my)) {
      app.tools.setTool(new MoveTool());
      return true;
    }
    if (btnCrop.hit(mx, my)) {
      app.tools.setTool(new CropTool(app.history));
      return true;
    }
    if (btnUndo.hit(mx, my)) {
      app.history.undo(app.doc);
      return true;
    }
    if (btnRedo.hit(mx, my)) {
      app.history.redo(app.doc);
      return true;
    }

    return true; // consume clicks on panel
  }

  boolean handleMouseDragged(App app, int mx, int my, int btn) {
    return (mx >= RightpanelX);
  }
  boolean handleMouseReleased(App app, int mx, int my, int btn) {
    return (mx >= RightpanelX);
  }
  boolean handleMouseWheel(App app, float delta) {
    return false;
  }

  void openFileDialog() {
    selectInput("Select an image", "fileSelected");
  }

  void onFileSelected(Document doc, File selection) {
    if (selection == null) return;
    PImage img = loadImage(selection.getAbsolutePath());
    if (img == null) return;

    // Append the layer instead of replacing so users can stack multiple images.
    Layer newLayer = new Layer(img);
    newLayer.name = selection.getName();

    boolean firstLayer = doc.layers.list.isEmpty();
    history.perform(doc, new AddLayerCommand(newLayer, doc.layers.list.size(), firstLayer));
    refreshLayerList(doc);
  }

  // ---------- Swing layer list helpers ----------
  void setupLayerPanel() {
    layerModel = new DefaultListModel<String>();
    layerList = new JList<String>(layerModel);
    layerList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
    layerList.setVisibleRowCount(-1);
    layerList.setDragEnabled(true);
    layerList.setDropMode(DropMode.INSERT);
    layerList.setTransferHandler(new LayerReorderHandler());

    // Rename on double-click so the UI feels like a lightweight Photoshop layer list.
    layerList.addMouseListener(new MouseAdapter() {
      public void mouseClicked(java.awt.event.MouseEvent e) {
        if (e.getClickCount() == 2) {
          promptRename();
        }
      }
    });

    layerList.addListSelectionListener(new ListSelectionListener() {
      public void valueChanged(ListSelectionEvent e) {
        if (e.getValueIsAdjusting()) return;
        int idx = layerList.getSelectedIndex();
        if (idx != document.layers.getActiveIndex()) {
          document.layers.setActiveIndex(idx);
        }
      }
    });

    layerScroll = new JScrollPane(layerList);
    layerScroll.setBorder(BorderFactory.createTitledBorder("Layers"));

    swingOverlay = new JPanel(null);
    swingOverlay.setOpaque(false);
    swingOverlay.add(layerScroll);

    SwingUtilities.invokeLater(new Runnable() {
      public void run() {
        PSurfaceAWT.SmoothCanvas canvas = (PSurfaceAWT.SmoothCanvas) surface.getNative();
        JFrame frame = (JFrame) canvas.getFrame();
        frame.getLayeredPane().add(swingOverlay, JLayeredPane.PALETTE_LAYER);
        updateSwingPanelBounds();
      }
    });
  }

  void updateSwingPanelBounds() {
    if (swingOverlay == null) return;
    int listHeight = height - 260; // Leave room for the existing Processing buttons
    swingOverlay.setBounds(0, 0, width, height);
    layerScroll.setBounds(RightpanelX + 8, 230, RightpanelW - 16, max(120, listHeight));
    swingOverlay.revalidate();
    swingOverlay.repaint();
  }

  void refreshLayerList(Document doc) {
    if (layerModel == null) return;
    // mirror layer names into the Swing list
    if (layerModel.getSize() != doc.layers.list.size()) {
      layerModel.removeAllElements();
      for (Layer l : doc.layers.list) {
        layerModel.addElement(l.name);
      }
    } else {
      for (int i = 0; i < doc.layers.list.size(); i++) {
        String existing = layerModel.get(i);
        String target = doc.layers.list.get(i).name;
        if (!existing.equals(target)) {
          layerModel.set(i, target);
        }
      }
    }

    if (doc.layers.getActiveIndex() != layerList.getSelectedIndex()) {
      int activeIdx = doc.layers.getActiveIndex();
      if (activeIdx >= 0 && activeIdx < layerModel.getSize()) {
        layerList.setSelectedIndex(activeIdx);
      } else {
        layerList.clearSelection();
      }
    }
  }

  void promptRename() {
    int idx = layerList.getSelectedIndex();
    if (idx < 0) return;
    Layer target = document.layers.list.get(idx);
    String newName = JOptionPane.showInputDialog("Rename layer", target.name);
    if (newName != null) {
      history.perform(document, new RenameLayerCommand(target, newName));
      refreshLayerList(document);
    }
  }

  // Create a blank transparent layer using the current canvas size.
  void createBlankLayer(Document doc) {
    PImage img = createImage(doc.canvas.w, doc.canvas.h, ARGB);
    img.format = ARGB;
    Layer layer = new Layer(img);
    layer.name = "Layer " + (doc.layers.list.size() + 1);
    history.perform(doc, new AddLayerCommand(layer, doc.layers.list.size()));
    refreshLayerList(doc);
  }

  void deleteActiveLayer(Document doc) {
    int idx = doc.layers.getActiveIndex();
    if (idx < 0) return;
    Layer target = doc.layers.getActive();
    history.perform(doc, new RemoveLayerCommand(target, idx));
    refreshLayerList(doc);
  }

  class LayerReorderHandler extends TransferHandler {
    protected Transferable createTransferable(JComponent c) {
      return new StringSelection(Integer.toString(layerList.getSelectedIndex()));
    }

    public int getSourceActions(JComponent c) {
      return MOVE;
    }

    public boolean canImport(TransferSupport support) {
      return support.isDataFlavorSupported(DataFlavor.stringFlavor);
    }

    public boolean importData(TransferSupport support) {
      if (!canImport(support)) return false;
      JList.DropLocation dl = (JList.DropLocation) support.getDropLocation();
      int index = dl.getIndex();
      try {
        int from = Integer.parseInt((String) support.getTransferable().getTransferData(DataFlavor.stringFlavor));
        if (from == index) return false;
        if (index > layerModel.getSize()) index = layerModel.getSize();

        int targetIndex = index;
        if (from < targetIndex) targetIndex--;

        Layer moved = document.layers.list.get(from);
        history.perform(document, new MoveLayerCommand(moved, from, targetIndex));
        refreshLayerList(document);
        return true;
      }
      catch(Exception ex) {
        return false;
      }
    }
  }
}
class UIButton {
  int x, y, w, h;
  String label;

  UIButton(int x, int y, int w, int h, String label) {
    this.x=x;
    this.y=y;
    this.w=w;
    this.h=h;
    this.label=label;
  }

  boolean hit(int mx, int my) {
    return mx >= x && mx <= x+w && my >= y && my <= y+h;
  }

  void draw(boolean active) {
    stroke(90);
    fill(active ? 90 : 65);
    rect(x, y, w, h, 6);

    fill(235);
    textAlign(LEFT, CENTER);
    textSize(12);
    text(label, x+10, y + h/2);
    textAlign(LEFT, BASELINE);
  }
}