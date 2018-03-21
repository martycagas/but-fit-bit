package model;

import java.io.Serializable;
import java.util.Arrays;

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
 * Třída implementující strukturu zásobníku.
 *
 * Jde o třídu implementující všechny požadované operace nad zásobníkem. Představuje generický zásobník,
 * který je dále děděn jednotlivými zásobníky. Většina metod je zcela použitelných i dále, ostatní jsou
 * upravované v zděděných zásobnících.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 */
public class CardStack implements Serializable {
    /**
     * Samotný zásobník karet.
     *
     * Implementován pomocí pole. Velikost je nastavena v konstruktoru zásobníku.
     * @see model.Card
     */
    protected Card[] stack;
    /**
     * Index do pole karet.
     */
    protected int index;
    /**
     * Identifikátor zásobníku pro určení typu.
     *
     * Identifikátory následují konvenci:
     * id 0 -> drawStack
     * id 1 -> discardStack
     * id 2-5 -> targetStacks
     * id 6-12 -> boardStacks
     * id 13 -> dragStack
     */
    protected int identifier;

    /**
     * Vyjímka zásobníku.
     *
     * Vkládání do plného zásobníku.
     */
    public class CardStackFullException extends Exception {
        public CardStackFullException(String message) {
            super(message);
        }
    }
    /**
     * Vyjímka zásobníku.
     *
     * Vkládání do zásobníku porušuje pravidlo hry.
     */
    public class SolitaireRuleException extends Exception {
        public SolitaireRuleException(String message) {
            super(message);
        }
    }

    /**
     * Konstruktor zásobníku.
     * @param size maximální velikost zásobníku
     */
    public CardStack(int size) {
        this.stack = new Card[size];
        this.index = 0;
        this.identifier = -1;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + index;
        result = prime * result + Arrays.hashCode(stack);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        CardStack other = (CardStack) obj;
        return index == other.index && Arrays.equals(stack, other.stack);
    }

    /**
     * Vrátí kapacitu zásobníku
     * @see model.CardStack
     * @return int - maximální kapacita pole zásobníku
     */
    public int getSize() {
        return this.stack.length;
    }

    /**
     * Vrátí aktuální ukazatel v poli
     * Zároveň znamená aktuální počet prvků v poli
     * @see model.CardStack.index
     * @return int - ukazatel do pole zásobníku
     */
    public int getIndex() {
        return this.index;
    }

    /**
     * Vrátí typ zásobníku
     * @see model.CardStack.identifier
     * @return int - identifikátor zásobníku
     */
    public int getIdentifier() {
        return this.identifier;
    }

    /**
     * Vrátí pole zásobníku
     * @see model.CardStack.stack
     * @return Card[] - pole zásobníku
     */
    public Card[] getStack() { return this.stack; }

    /**
     * Nastaví nový index zásobníku
     * @see model.CardStack.index
     * @param newIndex nový index zásobníku
     */
    public void setIndex(int newIndex) { this.index = newIndex; }

    /**
     * Nastaví nový typ zásobníku
     * @see model.CardStack.identifier
     * @param newIndex nový identifikátor zásobníku
     */
    public void setIdentifier(int id) {
        this.identifier = id;
    }

    /**
     * Rozhodne, jestli je zadaná karta na vrcholu zásobníku
     * @see model.Card
     * @param card
     * @return true - karta je na vrcholu zásobníku
     *         false - karta není na vrcholu zásobníku
     */
    public boolean isCardOnTop(Card card) {
        return (this.stack[this.index - 1] == card);
    }

    /**
     * Bez respektování pravidel vloží kartu na zásobník.
     * @see model.Card
     * @param card karta, která má být vložena na zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     */
    public void push(Card card) throws CardStackFullException {
        if (this.index == this.stack.length) {
            throw new CardStackFullException("Cannot insert new card to a full stack.");
        }
        this.stack[this.index++] = card;
    }

    /**
     * Vloží kartu na zásobník, pokud je to v souladu s pravidly hry
     * Konzultujte další zásobníky pro detaily
     * @see model.Card
     * @see model.SolitaireModel
     *
     * @see model.BoardStack
     * @see model.DiscardStack
     * @see model.DrawStack
     * @see model.TargetStack
     * @param card karta, která má být vložena na zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     * @throws SolitaireRuleException vyjímka, pokud vlkádaná karta nesplňuje pravidla hry
     */
    public void gamePush(Card card) throws CardStackFullException, SolitaireRuleException {
        if (this.index >= this.stack.length) {
            throw new CardStackFullException("Cannot insert new card to a full stack.");
        }
        this.stack[this.index++] = card;
    }

    /**
     * Odebere kartu ze zásobníku a vrátí ji
     * @return null - zásobník je prázdný
     *         Card - karta z vrcholu zásobníku
     */
    public Card pop() {
        if (this.index == 0) return null;
        else return this.stack[--this.index];
    }

    /**
     * Vrátí kartu na indexu v zásobníku
     * @param i index karty
     * @return null - zásobník je prázdný
     *         Card - karta z vrcholu zásobníku
     */
    public Card getCard(int i) {
        if (i < 0 || i > this.index) return null;
        else return this.stack[i];
    }

    /**
     * Za použití metody push přeloží karty ze zásobníku otherStack na zásobník
     * @see model.CardStack.push()
     * @param otherStack druhý zásobník
     */
    public void pushStack(CardStack otherStack) {
        int undo = this.getIndex();
        for (int i = 0; i < otherStack.getIndex(); i++) {
            try {
                this.push(otherStack.getCard(i));
            } catch (CardStackFullException except) {
                System.err.print("Error originating in pushStack:\n" + except + "\n");
                this.setIndex(undo);
                return;
            }
        }
        otherStack.setIndex(0);
    }

    /**
     * Za použití metody gamePush přeloží karty ze zásobníku otherStack na zásobník
     * @see model.CardStack.gamePush()
     * @param otherStack druhý zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     * @throws SolitaireRuleException vyjímka, pokud vlkádaná karta nesplňuje pravidla hry
     */
    public void gamePushStack(CardStack otherStack) throws CardStackFullException, SolitaireRuleException {
        int undo = this.getIndex();
        for (int i = 0; i < otherStack.getIndex(); i++) {
            Card c = otherStack.getCard(i);
            try {
                this.gamePush(c);
            } catch (CardStackFullException except) {
                this.setIndex(undo);
                throw new CardStackFullException("Error originating in gamePushStack:\n" + except);
            } catch (SolitaireRuleException except) {
                this.setIndex(undo);
                throw new SolitaireRuleException("Error originating in gamePushStack:\n" + except);
            }
        }
        otherStack.setIndex(0);
    }

    /**
     * Prohledá zásobník na existenci karty card, pokud tam je, přesune do zásobníku stack
     * všechny karty od hledané karty výše
     * @see model.Card
     * @param card hledaná karta
     * @param stack cílový zásobník
     */
    public void takeFrom(Card card, CardStack stack) {
        int i;
        stack.setIndex(0);
        for (i = this.index - 1; i >= 0; i--) {
            if (this.getCard(i) == card) {
                stack.setIndex(0);
                try {
                    for (int j = i; j < this.index; j++) {
                        stack.gamePush(this.getCard(j));
                    }
                } catch (CardStackFullException | SolitaireRuleException except) {
                    System.err.print("Error originating in takeFrom:\n" + except + "\n");
                    return;
                }
                this.setIndex(i);
            }
        }
    }

    /**
     * Prohledá zásobník na existenci karty, pokud tam je, vrátí její index, pokud ne, vrací -1
     * @see model.Card
     * @param card hledaná karta
     * @return -1 když zadaná karta v zásobníku není
     *         int index hledané karty
     */
    public int findCard(Card card) {
        for (int i = 0; i < this.index; i++) {
            if (stack[i] == card) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Prohledá zásobník na existenci karty se jménem shodným s řetězcem s
     * @see model.Card
     * @param s název hledané karty
     * @return Card když hledaná karta v zásobníku je
     *         null když hledaná karta v zásobníku není
     */
    public Card findCardByName(String s) {
        for (int i = 0; i < this.index; i++) {
            if (stack[i].toString().equals(s)) {
                return stack[i];
            }
        }
        return null;
    }

    /*
    * Auxiliary dump methods
    */
    public void dumpStack() {
        System.out.print("Dumping stack" + this.toString() + "\n");
        for (int i = 0; i < this.index; i++) {
            System.out.print(this.stack[i].toString() + "\n");
        }
        System.out.print("=====================================\n");
    }
}
