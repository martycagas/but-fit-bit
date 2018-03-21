// only for MacOS
//import com.apple.eawt.Application;

import controller.SolitaireController;
import model.SolitaireModel;
import view.SolitaireView;

import javax.swing.*;
import java.awt.*;
import java.util.ArrayList;
import java.util.List;


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
 */


public class Main {
    public static void main(String[] args) {

        // Vytvoreni okna
        JFrame frame = new JFrame("Solitaire");

        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.setMinimumSize(new Dimension(800, 500));



        frame.getContentPane().setBackground(new Color(44, 112, 0));


        // Ikonka
        ImageIcon icon = new ImageIcon("pictures/icon.png");

        // Nastaveni ikony Windows
        frame.setIconImage(icon.getImage());


        // Nastaveni ikony MacOS
        //Application.getApplication().setDockIconImage(new ImageIcon("pictures/icon.png").getImage());

        // Spusteni kontroleru
        SolitaireController controller = new SolitaireController(frame, 1);


        frame.setSize(800, 500);
    }

}
