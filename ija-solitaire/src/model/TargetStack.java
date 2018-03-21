package model;

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
 * Třída implementující strukturu cílového zásobníku.
 *
 * Třída dědí veškeré operace ze třídy CardStack, krom operací ovlivněných pravidly hry.
 * Tyto se potom řídí pravidly daného zásobníku.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 *
 * @see model.CardStack
 */
public class TargetStack extends CardStack {
    private Card.Color stackColor;

    /**
     * Konstruktor zásobníku.
     *
     * Oproti konstruktoru nadtřídy nastaví i barvy zásobníku.
     * @param size maximální velikost zásobníku
     * @param color barva zásobníku
     */
    public TargetStack(int size, Card.Color color) {
        super(size);
        this.stackColor = color;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        if (!super.equals(o)) return false;

        TargetStack that = (TargetStack) o;

        return stackColor == that.stackColor;
    }

    @Override
    public int hashCode() {
        int result = super.hashCode();
        result = 31 * result + stackColor.hashCode();
        return result;
    }

    /**
     * Vloží kartu na zásobník, pokud je to v souladu s pravidly hry.
     *
     * Pravidla hry umožňují hráči dávat na zásobník pouze karty stejné barvy a hodnoty o jedna větší.
     *
     * @see model.Card
     * @see model.CardStack
     *
     * @param card karta, která má být vložena na zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     * @throws SolitaireRuleException vyjímka, pokud vlkádaná karta nesplňuje pravidla hry
     */
    @Override
    public void gamePush(Card card) throws CardStackFullException, SolitaireRuleException {
        if (this.index >= this.stack.length) {
            throw new CardStackFullException("Cannot insert new card to full target stack.");
        } else if (card.getColor() != stackColor) {
            throw new SolitaireRuleException("Cannot insert invalid color to target stack.");
        }
        if (this.index + 1 == card.getValue()) {
            this.stack[this.index++] = card;
        } else {
            throw new SolitaireRuleException("Cannot insert invalid value to target stack.");
        }
    }

    /**
     * Za použití metody gamePush přeloží karty ze zásobníku otherStack na zásobník.
     *
     * Pravdl ahry dovolují hráči vkládat pouze jednu kartu na zásobník.
     *
     * @see model.CardStack.gamePush()
     * @param otherStack druhý zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     * @throws SolitaireRuleException vyjímka, pokud vlkádaná karta nesplňuje pravidla hry
     */
    @Override
    public void gamePushStack(CardStack otherStack) throws CardStackFullException, SolitaireRuleException {
        if (otherStack.getIndex() != 1) throw new SolitaireRuleException("Must move only one card to TargetStack.\n");
        int undo = this.getIndex();
        try {
            this.gamePush(otherStack.getCard(otherStack.getIndex() - 1));
        } catch (CardStackFullException except) {
            this.setIndex(undo);
            throw new CardStackFullException("Error originating in gamePushStack:\n" + except);
        } catch (SolitaireRuleException except) {
            this.setIndex(undo);
            throw new SolitaireRuleException("Error originating in gamePushStack:\n" + except);
        }
        otherStack.setIndex(0);
    }
}
