NAME = proj2
EXEC = $(NAME)
sources = $(NAME).c

CC = gcc

CFLAGS = -std=gnu99 -Wall -Wextra -Werror -pedantic
LDFLAGS = -lrt -pthread

OBJFILES = $(sources:.c=.o)

.PHONY : all

all : $(EXEC)

%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(EXEC) : $(OBJFILES)
	$(CC) $(CFLAGS) -o $@ $(OBJFILES) $(LDFLAGS)

clean:
	rm -fv *.o core *.out

cleanall: clean
	$(RM) $(EXEC)
