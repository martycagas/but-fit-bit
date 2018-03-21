import re


class Search:
    """
        Class used for searching phrases based on regular expressions and wrapping found occurances in HTML-like tags.
    """
    def __init__(self, input_contents, python_table):
        """
            Search constructor
        :param input_contents: raw string acquired from input file
        :param python_table: parsed and translated table outputted by Formatparser
        """
        self.input_string = input_contents
        self.output_str = ''
        self.python_table = python_table

    def __str__(self):
        """
            Called upon str() cast.
            Returns the status of object instance.
        :return: str
        """
        return "Search object:" +\
               "\nInput string: " + self.input_string +\
               "\nOutput string: " + self.output_str +\
               "\nCurrent table: " + self.python_table

    def get_output_str(self):
        """
            Returns the input string used by the object.
        :return: str
        """
        return self.output_str

    def set_input_string(self, input_contents):
        """
            Sets a new input string to be used by the object.
        :param input_contents: new raw string acquired from input file
        """
        self.input_string = input_contents

    def set_python_table(self, python_table):
        """
            Sets a new format table to be used by the object.
        :param python_table: new parsed and translated table outputted by Formatparser
        """
        self.python_table = python_table

    def generate_output(self):
        """
            Generated the output string according to the rulse set by the format table.
        :return: integer according to the success of operation
        """
        syntax_pos = [''] * (len(self.input_string) + 1)
        for line in self.python_table:
            for find in re.finditer(line[0], self.input_string, re.DOTALL):
                if find.end() == find.start():
                    continue
                else:
                    syntax_pos[find.start()] = syntax_pos[find.start()] + line[1]
                    syntax_pos[find.end()] = line[2] + syntax_pos[find.end()]
        for index in range(len(self.input_string)):
            self.output_str += syntax_pos[index] + self.input_string[index]
        self.output_str += syntax_pos[len(self.input_string)]
        return 0
