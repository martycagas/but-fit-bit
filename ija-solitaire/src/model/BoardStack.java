package model;

import java.io.Serializable;

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
 * Třída implementující strukturu hracího zásobníku na hrací ploše.
 *
 * Třída dědí veškeré operace ze třídy CardStack, krom operací ovlivněných pravidly hry.
 * Tyto se potom řídí pravidly daného zásobníku.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 *
 * @see model.CardStack
 */
public class BoardStack extends CardStack {
    public BoardStack(int size) {
        super(size);
    }

    /**
     * Vloží kartu na zásobník, pokud je to v souladu s pravidly hry.
     *
     * Kartu lze vložit pouze pokud je opačné barvy a o jedna menší hodnoty.
     *
     * @see model.Card
     * @see model.CardStack
     *
     * @param card karta, která má být vložena na zásobník
     * @throws CardStackFullException vyjímka, pokud je zásobník plný
     * @throws SolitaireRuleException vyjímka, pokud vlkádaná karta nesplňuje pravidla hry
     */
    @Override
    public void gamePush(Card card) throws CardStackFullException, SolitaireRuleException
    {
        if (this.index >= this.stack.length) {
            throw new CardStackFullException("Cannot insert new card to a full board stack.");
        }

        if (this.index == 0) {
            if (card.getValue() == 13) {
                this.stack[this.index++] = card;
            } else {
                throw new SolitaireRuleException("Must insert a King to an empty board stack.");
            }
        } else {
            if (this.stack[this.index - 1].similarColorTo(card)) {
                throw new SolitaireRuleException("Must insert card that isn't similar color to board stack.");
            } else {
                if (this.stack[this.index - 1].compareValue(card) == 1) {
                    this.stack[this.index++] = card;
                } else {
                    throw new SolitaireRuleException("Value must be one lower.");
                }
            }
        }
    }
}
