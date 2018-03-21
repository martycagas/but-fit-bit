package model;

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
 * Třída implementující strukturu odhazovacího zásobníku.
 *
 * Třída dědí veškeré operace ze třídy CardStack, krom operací ovlivněných pravidly hry.
 * Tyto se potom řídí pravidly daného zásobníku.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 *
 * @see model.CardStack
 */
public class DiscardStack extends CardStack {
    public DiscardStack(int size) {
        super(size);
    }

    /**
     * Vloží kartu na zásobník, pokud je to v souladu s pravidly hry.
     *
     * Pravidla hry neumožňují hráči dávat karty na odkládací balíček.
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
        throw new SolitaireRuleException("Cannot insert card to DiscardStack.");
    }
}