CC=gcc
CFLAGS=-std=c99 -Wall -pedantic -W -Wextra -Wno-unused-parameter -Wno-unused-variable

BIN=ipk-scanner
OBJ=main.o

GRINDPARAMS=--tool=memcheck --leak-check=yes --leak-check=full --show-leak-kinds=all

all: $(BIN)

%.o : %.c
	$(CC) $(CFLAGS) -c $<

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $(BIN) $(OBJ) -lm
	rm -f *.o

rebuild: clean $(BIN)

clean:
	rm -f *.o
	rm -f $(BIN)
	rm -f *.gcno
	rm -f *.gcda

grind: $(BIN) $(TEST)
	valgrind $(GRINDPARAMS) ./$(BIN) $(TEST)
