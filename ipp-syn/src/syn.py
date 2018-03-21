#!/usr/bin/python

import sys
from Argparser import Argparser
from Filehandler import Filehandler
from Formatparser import Formatparser
from Search import Search


def main():
    """
        Main function that creates and manages objects and call their methods used through the script.
        It is called whenever is this file run using the Python interpreter.
    :return: integer according to the success of operation 
    """
    # create a new Argparser object and assign it parameters and options
    # parse arguments and perform validity verifications
    arg_parser = Argparser(sys.argv[1:], ['input=', 'output=', 'format=', 'br', 'help'])
    check = arg_parser.parse_args()
    if check != 0:
        exit(check)
    check = arg_parser.validate_args()
    if check == 101:
        exit(0)
    elif check != 0:
        exit(check)
    # create a new Filehandler object
    # open files and perform validity verifications
    file_handler = Filehandler(arg_parser.get_args())
    check = file_handler.open_files()
    if check != 0:
        file_handler.close_files()
        exit(check)
    # perform checks to verify if format file is unset or empty
    input_contents = file_handler.get_input_file().read()
    if file_handler.get_format_file() is None:
        if file_handler.get_br_rule():
            output_string = input_contents.replace("\n", "<br />\n")
        else:
            output_string = input_contents
        file_handler.get_output_file().write(output_string)
        file_handler.close_files()
        exit(0)
    format_contents = file_handler.get_format_file().read()
    if format_contents == '':
        if file_handler.get_br_rule():
            output_string = input_contents.replace("\n", "<br />\n")
        else:
            output_string = input_contents
        file_handler.get_output_file().write(output_string)
        file_handler.close_files()
        exit(0)
    # create a new Formatparser object
    # parse regular expressions and tags and perform validity checks
    form_parser = Formatparser(format_contents)
    check = form_parser.generate_format_table()
    if check != 0:
        file_handler.close_files()
        exit(check)
    check = form_parser.translate_format_table()
    if check != 0:
        file_handler.close_files()
        exit(check)
    # create a new Serach object
    # search for positions and generate output string
    search = Search(input_contents, form_parser.get_python_table())
    search.generate_output()
    # write the string, perform line-break substitution, if needed
    if file_handler.get_br_rule():
        output_string = search.get_output_str().replace('\n', "<br />\n")
    else:
        output_string = search.get_output_str()
    file_handler.get_output_file().write(output_string)
    file_handler.close_files()
    exit(0)


if __name__ == '__main__':
    main()
