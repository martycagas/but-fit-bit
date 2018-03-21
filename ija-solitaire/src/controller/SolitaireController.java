package controller;

import model.SolitaireModel;
import view.SolitaireView;

import javax.swing.*;
import java.io.*;


/**
 *
 * Created by:
 * Jan Barton
 * Martin Cagas
 *
 * project IJA
 *
 * May 2017
 *
 *
 *
 * Solitaire Controller
 * Stara se o ukladani her. Obsahuje instanci modelu.
 */


public class SolitaireController {

    private SolitaireModel model;
    private boolean lastLoadUndo;
    private int undoCounter;
    private int undoLimit;
    private int gameID;

    /**
     * Inicializuje soubory, View a Model
     * @param frame okno
     */
    public SolitaireController(JFrame frame, int gameID) {

        this.gameID = gameID;

        // Vytvoreni modelu
        this.model = new SolitaireModel();

        // Vytvoreni view
        SolitaireView view = new SolitaireView(frame, this, gameID);

        this.undoCounter = 0;
        this.undoLimit = 10;
        this.lastLoadUndo = true;

        File dataDir = new File("../examples");
        File undoDir = new File("../examples/undo");
        if (!dataDir.exists()) {
            try {
                boolean success = dataDir.mkdir();
                if (!success) {
                    System.err.print("Failed to create new directory!\n");
                }
            }
            catch(SecurityException except) {
                System.err.print("Error occurred during creation of a data directory.\n" + except + "\n");
            }
        }
        if (!undoDir.exists()) {
            try {
                boolean success = undoDir.mkdir();
                if (!success) {
                    System.err.print("Failed to create new directory!\n");
                }
            }
            catch(SecurityException except) {
                System.err.print("Error occurred during creation of an undo directory.\n" + except + "\n");
            }
        }
        // save the initial state of the game as undo file
        this.storeUndo();
    }

    /**
     * Vrati aktualni model
     * @return SolitaireModel
     */
    public SolitaireModel getModel() {
        return this.model;
    }

    public void saveGame() {
        this.saveModel("../examples/save", this.gameID);
    }

    public void loadGame() {
        this.loadModel("../examples/save", this.gameID);
    }

    /**
     * ulozi aktualni hru do Undo souboru
     */
    public void storeUndo() {
        if (this.lastLoadUndo) {
            this.undoCounter += 1;
            if (this.undoCounter > this.undoLimit) {
                this.undoCounter = 0;
            }
        }
        String path = "../examples/undo/undo" + this.gameID + "-";
        this.saveModel(path, this.undoCounter);
        this.undoCounter += 1;
        if (this.undoCounter > this.undoLimit) {
            this.undoCounter = 0;
        }
        this.lastLoadUndo = false;
    }

    /**
     * nahraje hru z Undo souboru
     */
    public void loadUndo(boolean undo) {
        if (undo) {
            if (!this.lastLoadUndo) {
                this.undoCounter -= 1;
                if (this.undoCounter < 0) {
                    this.undoCounter = this.undoLimit;
                }
            }
            this.undoCounter -= 1;
        } else {
            if (!this.lastLoadUndo) {
                this.undoCounter += 1;
                if (this.undoCounter > this.undoLimit) {
                    this.undoCounter = 0;
                }
            }
            this.undoCounter += 1;
        }
        this.lastLoadUndo = true;
        if (this.undoCounter > this.undoLimit) {
            this.undoCounter = 0;
        } else if (this.undoCounter < 0) {
            this.undoCounter = this.undoLimit;
        }
        String path = "../examples/undo/undo" + this.gameID + "-";
        this.loadModel(path, this.undoCounter);
    }

    /* Static methods */

    /**
     * Ulozi model do souboru
     * @param filepath soubor
     * @param id cislo souboru
     */
    private void saveModel(String filepath, int id) {
        File file = new File(filepath + id + ".sgs");
        FileOutputStream streamOut = null;
        ObjectOutputStream oos = null;
        try {
            streamOut = new FileOutputStream(file, false);
            oos = new ObjectOutputStream(streamOut);
            oos.writeObject(this.model);
        } catch (FileNotFoundException except) {
            System.err.print("Failed to open the FileInputStream file:\n" + except + "\n");
        } catch (Exception except) {
            except.printStackTrace(System.err);
        } finally {
            try {
                if (streamOut != null) {
                    streamOut.close();
                }
                if (oos != null) {
                    oos.close();
                }
            } catch (IOException except) {
                System.err.print("Failed to close the FileInputStream file:\n" + except + "\n");
            }
        }
    }

    /**
     * Nahraje model ze souboru
     * @param filepath soubor
     * @param id cislo souboru
     */
    private void loadModel(String filepath, int id) {
        File file = new File(filepath + id + ".sgs");
        FileInputStream streamIn = null;
        try {
            streamIn = new FileInputStream(file);
            ObjectInputStream objectinputstream  = new ObjectInputStream(streamIn);
            this.model = (SolitaireModel) objectinputstream.readObject();
        } catch (FileNotFoundException except) {
            System.out.print("Requested file does not exist.\n");
        } catch (Exception except) {
            except.printStackTrace(System.err);
        } finally {
            try {
                if (streamIn != null) {
                    streamIn.close();
                }
            } catch (IOException except) {
                System.err.print("Failed to close the FileOutputStream file:\n" + except + "\n");
            }
        }
    }
}