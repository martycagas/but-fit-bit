package view;

import controller.SolitaireController;
import model.Card;
import model.DragStack;
import model.SolitaireModel;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.Color;
import model.CardStack;


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
 * Solitaire View
 * Vytvori a nasklada vsechny komponenty do JLayeredPane a jej prida do JFrame
 */


public class SolitaireView {

    private int gameID;
    private JFrame frame;

    /**
     * Vytvori a nasklada vsechny komponenty do JLayeredPane a jej prida do JFrame
     * @param frame okno
     * @param controller bere z nej model
     */
    public SolitaireView(JFrame frame, SolitaireController controller, int gameID) {

        this.gameID = gameID;
        this.frame = frame;

        // Hra 1
        JLayeredPane pane = new JLayeredPane();

        pane.setBackground(new Color(44, 112, 0));
        pane.setOpaque(true);


        // vytvoreni click labelu na vraceni balicku
        CardView drawStackBottom = new CardView("draw_stack_bottom", 20, 10);
        pane.add(drawStackBottom);
        pane.setLayer(drawStackBottom, -1);


        // vytvoreni labelu na spodek target Stacku
        CardView targetStackBottom1 = new CardView("target_stack_bottom_clubs", 350, 10);
        CardView targetStackBottom2 = new CardView("target_stack_bottom_diamonds", 460, 10);
        CardView targetStackBottom3 = new CardView("target_stack_bottom_hearts", 570, 10);
        CardView targetStackBottom4 = new CardView("target_stack_bottom_spades", 680, 10);
        pane.add(targetStackBottom1);
        pane.add(targetStackBottom2);
        pane.add(targetStackBottom3);
        pane.add(targetStackBottom4);
        pane.setLayer(targetStackBottom1, -1);
        pane.setLayer(targetStackBottom2, -1);
        pane.setLayer(targetStackBottom3, -1);
        pane.setLayer(targetStackBottom4, -1);


        // Vytvoreni vsech cardViews
        CardView [] cardViews = new CardView [52];

        for (int i = 0; i < 52; i += 13) {
            for (int j = 0; j <= 12; j++) {
                String name;

                if (j == 0) {
                    name = "ace";
                } else if (j <= 9) {
                    name = Integer.toString(j+1);
                } else if (j == 10) {
                    name = "jack";
                } else if (j == 11) {
                    name = "queen";
                } else {
                    name = "king";
                }

                name = name + "_of_";

                if (i == 0) {
                    name = name + "clubs";
                } else if (i == 13) {
                    name = name + "diamonds";
                } else if (i == 26) {
                    name = name + "hearts";
                } else {
                    name = name + "spades";
                }

                cardViews[i+j] = new CardView(name,20, 10);

            }
        }

        for (int i = 0; i < 52; i ++) {
            cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);
        }

        for (int i = 0; i < 52; i ++) {
            pane.add(cardViews[i]);
        }



        // Listener
        MouseAdapter adapter = new MouseAdapter() {

            private CardView selectedLabel = null;
            private Point selectedLabelLocation = null;
            private Point panelClickPoint = null;
            private boolean isMovable = false;

            private CardStack originStack = null;
            private DragStack dragStack = null;
            private Card selectedCard = null;
            private CardStack destStack = null;

            // PRESSED
            @Override
            public void mousePressed(final MouseEvent e) {

                dragStack = controller.getModel().getDragStack();

                //Find which label is at the press point:
                final Component pressedComp = pane.findComponentAt(e.getX(), e.getY());

                //If a label is pressed, store it as selected:
                if (pressedComp != null && pressedComp instanceof JLabel) {
                    selectedLabel = (CardView) pressedComp;
                    selectedLabelLocation = selectedLabel.getLocation();
                    panelClickPoint = e.getPoint();
                    //Added the following 2 lines in order to make selectedLabel
                    //paint over all others while it is pressed and dragged:


                    if (selectedLabel.isFacedUp()) {

                        selectedCard = controller.getModel().getCardByName(selectedLabel.getNameOfCard());


                        // puvodni balicek
                        originStack = controller.getModel().getStack(selectedCard);

                        originStack.takeFrom(selectedCard, dragStack);


                        isMovable = true;
                    } else {
                        isMovable = false;
                    }
                }
                else {
                    selectedLabel = null;
                    selectedLabelLocation = null;
                    panelClickPoint = null;
                }
            }

            // DRAGGED
            @Override
            public void mouseDragged(final MouseEvent e) {
                if (selectedLabel != null
                        && selectedLabelLocation != null
                        && panelClickPoint != null
                        && isMovable) {

                    final Point newPanelClickPoint = e.getPoint();

                    //The new location is the press-location plus the length of the drag for each axis:
                    final int newX = selectedLabelLocation.x + (newPanelClickPoint.x - panelClickPoint.x),
                            newY = selectedLabelLocation.y + (newPanelClickPoint.y - panelClickPoint.y);

                    dragStack.setXCoordinate(newX);
                    dragStack.setYCoordinate(newY);

                    // prekresli vsechny karty v dragStack
                    for (int i = 0; i < 52; i++) {
                        cardViews[i].repaintInDrag(controller.getModel(), pane);
                    }

                }
            }

            // RELEASED
            @Override
            public void mouseReleased(final MouseEvent e){
                if (selectedLabel != null
                        && selectedLabelLocation != null
                        && panelClickPoint != null) {

                    // klikaci operace
                    if (!isMovable) {
                        // fill Draw Stack
                        if (selectedLabel.getNameOfCard().equals("draw_stack_bottom")) {
                            controller.storeUndo();
                            controller.getModel().fillDrawStack();

                            // prekresli vsechny karty
                            for (int i = 0; i < 52; i++) {
                                cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);
                            }
                            return;

                            // target Stacks - dont do anything
                        } else if (selectedLabel.getNameOfCard().equals("target_stack_bottom_clubs")) {
                            return;
                        } else if (selectedLabel.getNameOfCard().equals("target_stack_bottom_hearts")) {
                            return;
                        } else if (selectedLabel.getNameOfCard().equals("target_stack_bottom_diamonds")) {
                            return;
                        } else if (selectedLabel.getNameOfCard().equals("target_stack_bottom_spades")) {
                            return;


                        } else {
                            originStack = controller.getModel().getStack(controller.getModel().getCardByName(selectedLabel.getNameOfCard()));
                            selectedCard = controller.getModel().getCardByName(selectedLabel.getNameOfCard());


                            // draw Card
                            if (originStack.getIdentifier() == 0){

                                controller.getModel().drawCard();
                                controller.storeUndo();

                            // Otoceni karty
                            } else if(originStack.getIdentifier() >= 6 && originStack.getIdentifier() <= 12) {

                                if (originStack.isCardOnTop(selectedCard)){
                                    selectedCard.turnFaceUp();
                                    controller.storeUndo();

                                }
                            }

                            // repaint
                            selectedLabel.setRightLocationAndPicture(controller.getModel(), pane);
                        }

                    // presouvani karet
                    } else {

                        if((destStack = getStackByCoordinates(e.getX(),e.getY(), controller.getModel())) != null){
                            try {
                                //destStack.pushStack(dragStack);
                                destStack.gamePushStack(dragStack);
                                controller.storeUndo();

                                int j = 0;
                                Card viewcard;
                                while ((viewcard = destStack.getCard(j)) != null) {
                                    j++;
                                    for (int i = 0; i < 52; i++) {
                                        if (viewcard.toString().equals(cardViews[i].getNameOfCard())) {
                                            cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);

                                        }
                                    }
                                }
                            } catch (CardStack.CardStackFullException | CardStack.SolitaireRuleException except) {
                                System.err.print(except + "\n");
                                originStack.pushStack(dragStack);
                                int j = 0;
                                Card viewcard;
                                while ((viewcard = originStack.getCard(j)) != null) {
                                    j++;
                                    for (int i = 0; i < 52; i++) {
                                        if (viewcard.toString().equals(cardViews[i].getNameOfCard())) {
                                            cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);

                                        }
                                    }
                                }
                            }
                        } else {

                            // karta byla pustena
                            originStack.pushStack(dragStack);
                            int j = 0;
                            Card viewcard;
                            while ((viewcard = originStack.getCard(j)) != null) {
                                j++;
                                for (int i = 0; i < 52; i++) {
                                    if (viewcard.toString().equals(cardViews[i].getNameOfCard())) {
                                        cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);

                                    }
                                }
                            }
                        }


                        // nastavi prislusne karte polohu
                        selectedLabel.setRightLocationAndPicture(controller.getModel(), pane);
                    }

                }

            }
        };

        pane.addMouseMotionListener(adapter);
        pane.addMouseListener(adapter);


        // JButtons
        JButton undo = new JButton("undo");
        JButton redo = new JButton("redo");
        JButton load = new JButton("load");
        JButton save = new JButton("save");
        JButton newGame = new JButton("new game");
        undo.setBounds(240, 10, 80, 20);
        redo.setBounds(240, 35, 80, 20);
        load.setBounds(240, 60, 80, 20);
        save.setBounds(240, 85, 80, 20);
        newGame.setBounds(240, 110, 80, 20);

        load.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                controller.storeUndo();
                controller.loadGame();

                for (int i = 0; i < 52; i ++) {
                    cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);
                }
            }
        });

        save.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                controller.saveGame();
            }
        });

        undo.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                controller.loadUndo(true);

                for (int i = 0; i < 52; i ++) {
                    cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);
                }
            }
        });

        redo.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                controller.loadUndo(false);

                for (int i = 0; i < 52; i ++) {
                    cardViews[i].setRightLocationAndPicture(controller.getModel(), pane);
                }
            }
        });

        newGame.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                createNewGame();

                newGame.setVisible(false);
                pane.remove(newGame);

            }
        });


        pane.add(undo);
        pane.add(redo);
        pane.add(load);
        pane.add(save);
        if (gameID<4) {
            pane.add(newGame);
        }



        Dimension maxSize = new Dimension(800, 500);

        pane.setPreferredSize(maxSize);

        // Panel obaluje JLayeredPane z duvodu posunuti
        JPanel panel = new JPanel();
        panel.setSize(maxSize);

        if (gameID==1) {
            panel.setLocation(0,0);
        } else if(gameID == 2) {
            frame.setMinimumSize(new Dimension(1600,500));
            panel.setLocation(800,0);
        } else if(gameID == 3) {
            frame.setMinimumSize(new Dimension(1600,1000));
            panel.setLocation(0,500);
        } else if(gameID == 4) {
            //frame.setMinimumSize(new Dimension(1600,1000));
            panel.setLocation(800,500);
        }


        panel.setBackground(new Color(44, 112, 0));
        panel.add(pane);


        frame.getContentPane().setLayout(null);
        frame.add(panel);



        frame.pack();
        frame.setVisible(true);






    }

    /**
     * Podle souradnic najde prislusny Stack
     * @param x prislusna x souradnice
     * @param y prislusna y souradnice
     * @param model prislusny model
     * @return CardStack, jinak null
     */
    private static CardStack getStackByCoordinates(int x, int y, SolitaireModel model){


        // boardStacks
        if (y > 140 && y < 500) {
            if (x > 20 && x < 100) {
                return model.getBoardStack(0);
            } else if (x > 130 && x < 210) {
                return model.getBoardStack(1);
            } else if (x > 240 && x < 320) {
                return model.getBoardStack(2);
            } else if (x > 350 && x < 430) {
                return model.getBoardStack(3);
            } else if (x > 460 && x < 540) {
                return model.getBoardStack(4);
            } else if (x > 570 && x < 650) {
                return model.getBoardStack(5);
            } else if (x > 680 && x < 760) {
                return model.getBoardStack(6);
            }

        } else if (y > 10 && y < 126) {
            if (x > 350 && x < 430) {
                return model.getTargetStack(0);
            } else if (x > 460 && x < 540) {
                return model.getTargetStack(1);
            } else if (x > 570 && x < 650) {
                return model.getTargetStack(2);
            } else if (x > 680 && x < 760) {
                return model.getTargetStack(3);
            }
        }

        return null;
    }


    public void createNewGame(){
        if (gameID <= 3) {
            SolitaireController controller = new SolitaireController(frame, gameID + 1);
        }
    }

}
