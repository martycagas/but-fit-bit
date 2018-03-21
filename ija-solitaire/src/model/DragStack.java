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
 * Třída implementující strukturu zásobníku karet na ruce.
 *
 * Třída dědí veškeré operace ze třídy CardStack, krom operací ovlivněných pravidly hry.
 * Tyto se potom řídí pravidly daného zásobníku.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 *
 * @see model.CardStack
 */
public class DragStack extends CardStack {
    /**
     * X-ová souřadnice balíčku na hracý ploše.
     */
    private int xCoordinate;
    /**
     * Y-ová souřadnice balíčku na hracý ploše.
     */
    private int yCoordinate;

    /**
     * Konstruktor se odlišuje od model.CardStack i inicializováním souřadnic na 0.
     *
     * @param size velikost zásobníku karet
     */
    public DragStack(int size) {
        super(size);
        this.xCoordinate = 0;
        this.yCoordinate = 0;
    }

    /**
     * Získá X-ovou souřadnici balíčku.
     *
     * @return X-ová souřadnice balíčku
     */
    public int getXCoordinate() {
        return this.xCoordinate;
    }

    /**
     * Získá Y-ovou souřadnici balíčku.
     *
     * @return Y-ová souřadnice balíčku
     */
    public int getYCoordinate() {
        return this.yCoordinate;
    }

    /**
     * Nastaví X-ovou souřadnici balíčku.
     *
     * @return nová X-ová souřadnice balíčku
     */
    public void setXCoordinate(int i) {
        this.xCoordinate = i;
    }

    /**
     * Nastaví Y-ovou souřadnici balíčku.
     *
     * @return nová Y-ová souřadnice balíčku
     */
    public void setYCoordinate(int i) {
        this.yCoordinate = i;
    }
}