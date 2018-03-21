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
 * Třída implementující základn kartu.
 *
 * Tato třída obsahuje všechny potřebné metody pro práci s kartou, ať už jsou to getery či setery atributů karty,
 * či metody na porovnání karet a převedení na řetězec.
 *
 * Třída implementuje java.io.Serializable aby bylo možné ji ukládat přes ObjectStream.
 */
public class Card implements Serializable {
    /**
     * Nested třída představující výčtový typ barvy karty.
     *
     * Krom čtyř samotných hodnot představujících barvu karty obsahuje i metodu pro jednoduché peřvádění na řetězec.
     */
    public enum Color {
        /**
         * Výčet barevných hodnot:
         * CLUBS - kříže
         * DIAMONDS - káry
         * HEARTS - srdce
         * SPADES - piky
         */
        CLUBS("clubs"), DIAMONDS("diamonds"), HEARTS("hearts"), SPADES("spades");

        /**
         * Řetězec uchovávající slovní hodnotu karty.
         */
        private final String constructorString;

        /**
         * Kontruktor karty.
         *
         * @param s řetězec jednoznačně určující barvu karty
         */
        Color(final String s) {
            this.constructorString = s;
        }

        /**
         * Metoda volaná při převodu na řetězec.
         *
         * @return řetězec jednoznačně určující barvu karty
         */
        @Override
        public String toString() {
            return constructorString;
        }
    }

    /**
     * Hodnota karty.
     *
     * Hodnoty 2 - 10 představují odpovídající hodnoty. Dále pak hodnota 1 představuje eso,
     * hodnota 11 janka, 12 královnu a 13 krále.
     */
    private int value;
    /**
     * Identifikuje, zda-li je karta otočená lícem vzhůru.
     *
     * Implicitní hodnota je False.
     */
    private boolean turnedFaceUp;
    /**
     * Určuje barvu karty.
     *
     * @see model.Card.Color
     */
    private Color color;

    /**
     * Konstruktor karty.
     *
     * Nastaví všechny atributy nové karty podle zadaných parametrů, případně implicitních hodnot.
     *
     * @param newColor barva nové karty
     * @param newValue hodnota nové karty
     */
    public Card(Color newColor, int newValue) {
        this.color = newColor;
        this.value = newValue;
        this.turnedFaceUp = false;
    }

    @Override
    public String toString() {
        if (this.value == 1) {
            return ("ace" + "_of_" + this.color.toString());
        } else if (this.value == 11) {
            return ("jack" + "_of_" + this.color.toString());
        } else if (this.value == 12) {
            return ("queen" + "_of_" + this.color.toString());
        } else if (this.value == 13) {
            return ("king" + "_of_" + this.color.toString());
        } else {
            return (Integer.toString(this.value) + "_of_" + this.color.toString());
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((color == null) ? 0 : color.hashCode());
        result = prime * result + value;
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

        Card other = (Card) obj;
        return color == other.color && value == other.value;
    }

    /**
     * Vrátí barvu karty.
     * @see model.Card.Color
     * @return barva karty
     */
    public Color getColor() {
        return this.color;
    }

    /**
     * Vrátí hodnotu karty.
     * @return hodnota karty
     */
    public int getValue() {
        return this.value;
    }

    /**
     * Vrátí informaci o tom, zda-li je karta otočená lícem vzhůru.
     *
     * @return true, pokud je karta otočená lícem vzhůru
     *         false, pokud karta není otočená lícem vzhůru
     */
    public boolean isTurnedFaceUp() {
        return this.turnedFaceUp;
    }

    /**
     * Otočí kartu lícem vzhůru. Pokud již tak otočená je, nedělá metoda nic.
     */
    public void turnFaceUp() {
        this.turnedFaceUp = true;
    }

    /**
     * Otočí kartu lícem dolů. Pokud již tak otočená je, nedělá metoda nic.
     */
    public void turnFaceDown() {
        this.turnedFaceUp = false;
    }

    /**
     * Porovná hodnotu karty card s hodnotou této karty a vrátí jejich rozdíl.
     *
     * Slouží k určování validity operací při pokládání karet.
     *
     * @param card karta, jejíž hodnota má být porovnána
     * @return rozdíl hodnot karet
     */
    public int compareValue(Card card)
    {
        return this.value - card.getValue();
    }

    /**
     * Porovná barvy dvou karet.
     *
     * @param card karta, jejíž barva má být porovnána
     * @return true, pokud barvy obou karet paří do množiny {HEARTS, DIAMONDS}
     *         true, pokud barvy obou karet paří do množiny {SPADES, CLUBS}
     *         false v opačných případech
     */
    public boolean similarColorTo(Card card)
    {
        if (this.color == Color.SPADES || this.color == Color.CLUBS) {
            if (card.getColor() == Color.SPADES || card.getColor() == Color.CLUBS) {
                return true;
            }
        } else {
            if (card.getColor() == Color.HEARTS || card.getColor() == Color.DIAMONDS) {
                return true;
            }
        }
        return false;
    }
}