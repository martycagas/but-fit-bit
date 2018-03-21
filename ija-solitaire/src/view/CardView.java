package view;

import model.CardStack;
import model.DragStack;
import model.SolitaireModel;
import javax.swing.*;
import java.awt.*;


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
 * Card View
 * JLabel predstavujici kartu v okne
 */

class CardView extends JLabel {

    private String nameOfCard;
    private boolean isFacedUp;
    private model.Card card;
    private CardStack stack;
    private int stackID;
    private int indexInStack;


    /**
     * Konstruktor karty
     * @param nameOfCard nazev karty
     * @param x defaultni souradnice x
     * @param y defaultni souradnice y
     */
    CardView(String nameOfCard, int x, int y) {
        this.nameOfCard = nameOfCard;
        this.setIcon(new ImageIcon(new ImageIcon("pictures/cards/" + nameOfCard + ".png").getImage().getScaledInstance(80, 116,Image.SCALE_SMOOTH)));

        int cardWidth = this.getPreferredSize().width;
        int cardHeight = this.getPreferredSize().height;

        this.setBounds(x, y, cardWidth, cardHeight);

        setLocation(x,y);

        isFacedUp = false;
    }

    /**
     * FaceUp getter
     * @return FaceUp
     */
    boolean isFacedUp() {
        return isFacedUp;
    }


    /**
     * NameOfCard getter
     * @return jmeno karty
     */
    String getNameOfCard() {
        return nameOfCard;
    }


    /**
     * Nastavi globalni promenne - najde k View prislusne instance Card, CardStack, StackID, ...
     * @param model prislusny model
     */
    private void setUpCardPosition(SolitaireModel model){
        // najde se instance Card podle jmena
        card = model.getCardByName(nameOfCard);

        // zjisti se otoceni karty
        this.isFacedUp = card.isTurnedFaceUp();

        // najde se Stack podle Card
        stack = model.getStack(card);

        // zjisti se typ Stacku
        stackID = stack.getIdentifier();
        /*
         * id 0 -> drawStack
         * id 1 -> discardStack
         * id 2-5 -> targetStacks
         * id 6-12 -> boardStacks
         * id 13 -> handStacks
         */

        // zjisti se pozice karty ve Stacku
        indexInStack = stack.findCard(card);
    }

    /**
     * Vykresli kartu na spravnem miste podle modelu
     * @param model prislusny model
     * @param panel prislusny pane
     */
    void setRightLocationAndPicture(SolitaireModel model, JLayeredPane panel) {

        setUpCardPosition(model);

        if (isFacedUp) {
            this.setIcon(new ImageIcon(new ImageIcon("pictures/cards/" + nameOfCard + ".png").getImage().getScaledInstance(80, 116,Image.SCALE_SMOOTH)));
        } else {
            this.setIcon(new ImageIcon(new ImageIcon("pictures/cards/card_back.png").getImage().getScaledInstance(80, 116,Image.SCALE_SMOOTH)));
        }



        // vypocte se poloha podle typu Stacku a pozice karty
        int x, y;

        if (stackID == 0) {         // drawStack
            x = 20;
            y = 10;

        } else if(stackID == 1) {   // discardStack
            x = 130;
            y = 10;

        } else if(stackID <= 5) {   // targetStack
            x = 350 + (stackID-2) * 110;
            y = 10;

        } else if (stackID <=12){   // boardStack
            x = 20 + (stackID-6) * 110;
            y = 140 + (indexInStack) * 15;

        } else {                    // dragStack
            DragStack drgstack = model.getDragStack();
            x = drgstack.getXCoordinate();
            y = drgstack.getXCoordinate() + (indexInStack) * 15;
        }

        // nastaveni vrstvy
        panel.setLayer(this, indexInStack);

        // nastaveni polohy
        setLocation(x, y);


    }

    /**
     * Vykresli karty uvnitr DragStack
     * @param model prislusny model
     * @param panel prislusny pane
     */
    void repaintInDrag(SolitaireModel model, JLayeredPane panel) {

        DragStack drgstack = model.getDragStack();

        int index = drgstack.findCard(card);

        // pouze karty ktere jsou v dragStack
        if (index >= 0) {
            int x = drgstack.getXCoordinate();
            int y = drgstack.getYCoordinate() + (index) * 15;

            // nastaveni vrstvy
            panel.setLayer(this, index + 50);

            // nastaveni polohy
            setLocation(x, y);
        }

    }


}
