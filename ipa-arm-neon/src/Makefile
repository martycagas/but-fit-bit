CC=gcc
CFLAGS=-mfpu=neon -march=armv7ve -std=c99 -Wall -pedantic \
-W -Wextra -Wno-unused-variable -Wno-unused-parameter

BIN=editor
OBJ=main.o algorithm.o

all: $(BIN)

%.o : %.c
	$(CC) $(CFLAGS) -c $<

$(BIN): $(OBJ)
	$(CC) $(CFLAGS) -o $(BIN) $(OBJ) -lm

rebuild: clean $(BIN)

clean:
	rm -f *.o
	rm -f $(BIN)
