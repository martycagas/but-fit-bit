package model;

import java.io.Serializable;
import java.util.Random;

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

/**
 * Třída představující model celé hry.
 *
 * Vytváří a uchovává všechny zásobníky hry, strará se opráci s kartami.
 */
public class SolitaireModel implements Serializable {
    /**
     * Lízací balíček hry.
     *
     * @see model.DrawStack
     */
    private DrawStack drawStack;
    /**
     * Odkládací balíček hry.
     *
     * @see model.DiscardStack
     */
    private DiscardStack discardStack;
    /**
     * Cílový balíček hry.
     *
     * Číslování balíčků podle hodnot barvy následuje pořadí podle enumu Color:
     * 0 ... clubs
     * 1 ... diamonds
     * 2 ... hearts
     * 3 ... spades
     *
     * @see model.Card.Color
     * @see model.TargetStack
     */
    private TargetStack[] targetStacks;
    /* total number of board stacks: 7 */
    /**
     * Herní balíček hry.
     *
     * @see model.BoardStack
     */
    private BoardStack[] boardStacks;
    /**
     * Přesouvací balíček hry.
     *
     * @see model.DrawStack
     */
    private DragStack dragStack;

    /**
     * Konstruktor modelu.
     *
     * Vytvoří všechny zásobníky a nastaví jim identifikátory. Poté inicializuje hru a otočí všechny
     * horní karty na všech balíčcích GameStack lícem vzhůru.
     *
     * @see model.CardStack
     */
    public SolitaireModel() {
        int id = 0;
        int i = 0;
        /*
         * id 0 -> drawStack
         * id 1 -> discardStack
         * id 2-5 -> targetStacks
         * id 6-12 -> boardStacks
         * id 13 -> dragStack
         */
        drawStack = new DrawStack(52);
        drawStack.setIdentifier(id++);

        discardStack = new DiscardStack(24);
        discardStack.setIdentifier(id++);

        targetStacks = new TargetStack[4];
        for (Card.Color color : Card.Color.values()) {
            targetStacks[i] = new TargetStack(13, color);
            targetStacks[i].setIdentifier(id++);
            i++;
        }

        boardStacks = new BoardStack[7];
        for (i = 0; i < 7; i++) {
            boardStacks[i] = new BoardStack(20);
            boardStacks[i].setIdentifier(id++);
        }

        dragStack = new DragStack(13);
        //noinspection UnusedAssignment
        dragStack.setIdentifier(id++);

        this.initGame();
        this.turnTopFaceUp();
    }

    /*
     * getters
     */

    /**
     * Vrátí aktuální DrawStack.
     *
     * @return DrawStack tohoto modelu
     */
    public DrawStack getDrawStack() {
        return this.drawStack;
    }
    /**
     * Vrátí aktuální DiscardStack.
     *
     * @return DiscardStack tohoto modelu
     */
    public DiscardStack getDiscardStack() {
        return this.discardStack;
    }

    /**
     * Vrátí aktuální TargetStack podle indexu.
     *
     * @param i index TargetStack, který chceme získat
     * @return TargetStack tohoto modelu podle indexu
     */
    public TargetStack getTargetStack(int i) {
        try {
            return this.targetStacks[i];
        } catch (java.lang.IndexOutOfBoundsException exception) {
            System.err.print("Cannot resolve target stack index.\n" + exception + "\n");
            return null;
        }
    }
    /**
     * Vrátí aktuální BoardStack podle indexu.
     *
     * @param i index BoardStack, který chceme získat
     * @return BoardStack tohoto modelu podle indexu
     */
    public BoardStack getBoardStack(int i) {
        try {
            return this.boardStacks[i];
        } catch (java.lang.IndexOutOfBoundsException exception) {
            System.err.print("Cannot resolve board stack index.\n" + exception + "\n");
            return null;
        }
    }
    /**
     * Vrátí aktuální DragStack.
     *
     * @return DragStack tohoto modelu
     */
    public DragStack getDragStack() {
        return this.dragStack;
    }

    /**
     * Inicializuje hru.
     *
     * Nejprve nastaví indexy všech zásobníků na 0, čímž je v vyprázdní.
     * Poté naplní DrawStack základním balíčkem karet pro kru Solitaire a zamíchá jej.
     * Z tohoto balíčku pak rozdá katy do BoardStacků modelu podle vzoru hry Solitaire.
     * Následně otočí vrchní karty všech BoardStacků lícem vzhůru.
     *
     * @see model.BoardStack
     * @see model.DiscardStack
     * @see model.DrawStack
     * @see model.TargetStack
     */
    private void initGame() {
        this.discardStack.setIndex(0);
        for (TargetStack targetStack : this.targetStacks) {
            targetStack.setIndex(0);
        }
        this.drawStack.setIndex(0);
        for (Card.Color c : Card.Color.values()) {
            for (int v = 1; v < 14; v++) {
                try {
                    this.drawStack.push(new Card(c, v));
                } catch (CardStack.CardStackFullException except) {
                    System.err.print("Error pushing to drawStack in initGame:\n" + except + "\n");
                    this.drawStack.setIndex(0);
                    return;
                }
            }
        }

        shuffleArray(this.drawStack.getStack());

        for (int i = 0; i < this.boardStacks.length; i++) {
            this.boardStacks[i].setIndex(0);
            for (int j = 0; j < i + 1; j++) {
                try {
                    this.boardStacks[i].push(this.drawStack.pop());
                } catch (CardStack.CardStackFullException except) {
                    System.err.print("Error pushing to boardStacks in initGame:\n" + except + "\n");
                    return;
                }
            }
        }
    }

    /**
     * Otočí všechny vrchní karty všechn BoardStacků tohoto modelu lícem vzhůru.
     *
     * @see model.BoardStack
     */
    public void turnTopFaceUp() {
        for (BoardStack boardStack : this.boardStacks) {
            Card c = boardStack.getCard(boardStack.getIndex() - 1);
            if (c != null) c.turnFaceUp();
        }
    }

    /**
     * Podle řetězce s vyhledá kartu ve všech balíčcích.
     *
     * @param s karta, kterou je potřeba vyhledat
     * @return Card, pokud je karta nalezena
     * @return null, pokud karta není nalezena
     */
    public Card getCardByName(String s) {
        Card cardByName;

        for (BoardStack boardStack : this.boardStacks) {
            cardByName = boardStack.findCardByName(s);
            if (cardByName != null) return cardByName;
        }
        for (TargetStack targetStack : this.targetStacks) {
            cardByName = targetStack.findCardByName(s);
            if (cardByName != null) return cardByName;
        }
        cardByName = drawStack.findCardByName(s);
        if (cardByName != null) return cardByName;
        cardByName = discardStack.findCardByName(s);
        if (cardByName != null) return cardByName;
        cardByName = dragStack.findCardByName(s);
        if (cardByName != null) return cardByName;

        System.err.print("Error in public Card getCardByName(String s)\n" +
                "Designated card name not found in any stack!\n");
        return null;
    }

    /**
     * Podle karty vyhledá balíček, ve kterém je karta uložena.
     *
     * @param card karta, jejíž balíček má být nalezen
     * @return CardStack, pokud je karta nalezena
     * @return null, pokud karta není nalezena
     */
    public CardStack getStack(Card card) {
        if (drawStack.findCard(card) != -1) return this.drawStack;
        if (discardStack.findCard(card) != -1) return this.discardStack;
        if (dragStack.findCard(card) != -1) return this.dragStack;
        for (BoardStack boardStack : this.boardStacks) {
            if (boardStack.findCard(card) != -1) return boardStack;
        }
        for (TargetStack targetStack : this.targetStacks) {
            if (targetStack.findCard(card) != -1) return targetStack;
        }
        System.err.print("Error in public CardStack getStack(Card card)\n" +
                "Designated card not found in any stack!\n");
        return null;
    }

    /**
     * Přesune kartu z DrawStack na DiscardStack s respektováním pravidel hry, tedy kartu otočí lícem vzhůru.
     *
     * @see model.DrawStack
     * @see model.DiscardStack
     */
    public void drawCard() {
        Card c = this.drawStack.pop();
        c.turnFaceUp();
        try {
            this.discardStack.push(c);
        } catch (CardStack.CardStackFullException except) {
            System.err.print("Error originating in public void drawCard():" + except + "\n");
        }
    }

    /**
     * Přesune karty z DiscardStack zpět na DrawStack a otočí je lícem dolů.
     *
     * @see model.DrawStack
     * @see model.DiscardStack
     */
    public void fillDrawStack() {
        int limit = this.discardStack.getIndex();
        for (int i = 0; i < limit; i++) {
            try {
                this.drawStack.push(this.discardStack.pop());
            } catch (CardStack.CardStackFullException except) {
                System.err.print("Error originating in public void fillDrawStack():" + except + "\n");
            }
        }
    }

    /*
     * Static methods
     */

    /**
     * Statická metoda, která provede náhodné promíchání pole.
     *
     * @param array pole, které má být promícháno
     */
    private static void shuffleArray(Card[] array) {
        int index;
        Card temp;
        Random random = new Random();
        for (int i = array.length - 1; i > 0; i--)
        {
            index = random.nextInt(i + 1);
            temp = array[index];
            array[index] = array[i];
            array[i] = temp;
        }
    }

    /*
    * Auxiliary dump methods
    */
    public void dumpModel() {
        System.out.print("Dumping SolitaireModel" + this.toString() + "\n");
        drawStack.dumpStack();
        dragStack.dumpStack();
        discardStack.dumpStack();
        for (BoardStack boardStack : this.boardStacks) {
            boardStack.dumpStack();
        }
        for (TargetStack targetStack : this.targetStacks) {
            targetStack.dumpStack();
        }
        System.out.print("*************************************\n");
        System.out.print("*************************************\n");
    }
}
