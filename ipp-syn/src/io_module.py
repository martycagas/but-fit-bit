import sys


def print_help():
    """
        Prints help to standard output.
        Warning - Exits the script!
    :return: 0 
    """
    print("--format = filename\t\turceni formatovacího souboru\n"
          "--input = filename\t\turceni vstupniho souboru v kodování UTF - 8\n"
          "--output = filename\t\turceni vystupniho souboru\n"
          "--br\t\t\t\t\tpridani elementu <br /> na konec kazdeho radku puvodniho vstupniho textu")
    exit(0)


def print_err(*args):
    """
        Prints arguments to the standard error output in the same way print() function does.
    :param args: list 
    """
    print(*args, file=sys.stderr)
