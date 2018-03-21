import re
import io_module
import Exceptions


class Formatparser:
    """
        Class used for translating both regular expressions and tags inputted in the format file
        to more Python-friendly formats that can be used.
    """
    def __init__(self, syn_table):
        """
            Formatparser constructor.
        :param syn_table: two-dimensional list containing raw format string
        """
        self.syn_format = syn_table
        self.format_table = []
        self.python_table = []

    def __str__(self):
        """
            Called upon str() cast.
            Returns the status of object instance.
        :return: str
        """
        return "Regparser object:" + \
               "\nInputted SYN dictionary: " + str(self.syn_format) + \
               "\nParsed format table: " + str(self.format_table) + \
               "\nTranslated format table: " + str(self.python_table)

    def get_format_table(self):
        """
            Returns parsed list in default SYN format.
        :return: list
        """
        return self.format_table

    def get_python_table(self):
        """
            Returns translated list that can be used for matching and text wrapping.
        :return: list
        """
        return self.python_table

    def set_syn_table(self, syn_table):
        """
            Sets new syn_table for the object.
        :param syn_table: two-dimensional list containing raw format string
        """
        self.syn_format = syn_table

    def generate_format_table(self):
        """
            Parses the raw string to more machine-readable form.
        :return: integer according to the success of operation
        """
        for row in self.syn_format.splitlines():
            column = row.split('\t', 1)
            # noinspection PyBroadException
            try:
                format_line = [column[0].strip(), column[-1].strip()]
            except:
                io_module.print_err("Error parsing the format file.")
                return 4
            self.format_table.append(format_line)
            python_line = format_line[:]
            python_line.append('')
            self.python_table.append(python_line)
        return 0

    def translate_format_table(self):
        """
            Translates the syn_table so that it can be used for matching and text wrapping.
            Table is a multi-dimensional list.
                [['python regex', 'opening tags, 'closing tags'][...] ...]
        :return: integer according to the success of operation
        """
        for row in range(0, len(self.format_table)):
            try:
                self.python_table[row][0] = self.translate_syn_regex(self.format_table[row][0])
                self.python_table[row][1], \
                    self.python_table[row][2] = self.translate_syn_tags(self.format_table[row][1])
            except Exceptions.RegexError:
                io_module.print_err("Invalid regex format.\n Details: regex on line " + str(row) + " is invalid.")
                return 4
            except Exceptions.TagError:
                io_module.print_err("Invalid tag format.\n Details: tag on line " + str(row) + " is invalid.")
                return 4
        return 0

    @staticmethod
    def translate_syn_regex(syn_regex):
        """
            Translates a regex to a Perl-style form to be usable in Python.
        :param syn_regex: regex in the default SYN format
        :return: string
        """
        index = 0
        python_regex = ""
        while index < len(syn_regex):
            if syn_regex[index] == '!':
                index += 1
                if index == len(syn_regex):
                    raise Exceptions.RegexError
                if syn_regex[index] == '%':
                    index += 1
                    if index == len(syn_regex):
                        raise Exceptions.RegexError
                    elif syn_regex[index] == 's':
                        python_regex += '[\\S]'
                    elif syn_regex[index] == 'a':
                        python_regex += '[^.]'
                    elif syn_regex[index] == 'd':
                        python_regex += '[\\D]'
                    elif syn_regex[index] == 'l':
                        python_regex += '[^a-z]'
                    elif syn_regex[index] == 'L':
                        python_regex += '[^A-Z]'
                    elif syn_regex[index] == 'w':
                        python_regex += '[^a-zA-Z]'
                    elif syn_regex[index] == 'W':
                        python_regex += '[^0-9a-zA-Z]'
                    elif syn_regex[index] == 't':
                        python_regex += '[^\t]'
                    elif syn_regex[index] == 'n':
                        python_regex += '[^\n]'
                    elif syn_regex[index] in '.|!*+()%':
                        python_regex += '[^\\' + syn_regex[index] + ']'
                    else:
                        raise Exceptions.RegexError
                elif syn_regex[index] in '.!|':
                    raise Exceptions.RegexError
                elif syn_regex[index] in '\\^[]{}$?':
                    python_regex += '[^\\' + syn_regex[index] + ']'
                elif syn_regex[index] == '(':
                    python_regex += syn_regex[index]
                    index += 1
                    if index == len(syn_regex) or syn_regex[index] == ')':
                        raise Exceptions.RegexError
                    else:
                        continue
                elif syn_regex[index] == ')':
                    python_regex += syn_regex[index]
                else:
                    python_regex += '[^' + syn_regex[index] + ']'
            elif syn_regex[index] == '%':
                index += 1
                if index == len(syn_regex):
                    raise Exceptions.RegexError
                elif syn_regex[index] == 's':
                    python_regex += '[\\s]'
                elif syn_regex[index] == 'a':
                    python_regex += '.'
                elif syn_regex[index] == 'd':
                    python_regex += '[\\d]'
                elif syn_regex[index] == 'l':
                    python_regex += '[a-z]'
                elif syn_regex[index] == 'L':
                    python_regex += '[A-Z]'
                elif syn_regex[index] == 'w':
                    python_regex += '[a-zA-Z]'
                elif syn_regex[index] == 'W':
                    python_regex += '[0-9a-zA-Z]'
                elif syn_regex[index] == 't':
                    python_regex += '[\t]'
                elif syn_regex[index] == 'n':
                    python_regex += '[\n]'
                elif syn_regex[index] in '.|!*+()%':
                    python_regex += '\\' + syn_regex[index]
                else:
                    raise Exceptions.RegexError
            elif syn_regex[index] == '.':
                if index == 0:
                    raise Exceptions.RegexError
                index += 1
                if index == len(syn_regex) or syn_regex[index] == '.':
                    raise Exceptions.RegexError
                else:
                    continue
            elif syn_regex[index] in '\\^[]{}$?':
                python_regex += '\\' + syn_regex[index]
            elif syn_regex[index] == '(':
                python_regex += syn_regex[index]
                index += 1
                if index == len(syn_regex) or syn_regex[index] == ')':
                    raise Exceptions.RegexError
                else:
                    continue
            elif syn_regex[index] == '|':
                if index == 0:
                    raise Exceptions.RegexError
                python_regex += syn_regex[index]
                index += 1
                if index == len(syn_regex) or syn_regex[index] == '|':
                    raise Exceptions.RegexError
                else:
                    continue
            else:
                python_regex += syn_regex[index]
            index += 1
        try:
            re.compile(python_regex)
        except re.error:
            raise Exceptions.RegexError
        return python_regex

    @staticmethod
    def translate_syn_tags(syn_tag):
        """
            Parses the default SYN tags to be directly usable in text insertions.
        :param syn_tag: string of tags in the raw SYN format
        :return: string, string
        """
        python_tag = ""
        python_tag_close = ""
        for tag in syn_tag.split(','):
            tag = tag.strip()
            if re.match(r'bold', tag):
                python_tag += '<b>'
                python_tag_close = '</b>' + python_tag_close
            elif re.match(r'italic', tag):
                python_tag += '<i>'
                python_tag_close = '</i>' + python_tag_close
            elif re.match(r'underline', tag):
                python_tag += '<u>'
                python_tag_close = '</u>' + python_tag_close
            elif re.match(r'teletype', tag):
                python_tag += '<tt>'
                python_tag_close = '</tt>' + python_tag_close
            elif re.match(r'size:[1-7]', tag):
                python_tag += '<font size=' + tag[5:] + '>'
                python_tag_close = '</font>' + python_tag_close
            elif re.match(r'color:[0-9a-fA-F]{6}', tag):
                python_tag += '<font color=#' + tag[6:] + '>'
                python_tag_close = '</font>' + python_tag_close
            else:
                raise Exceptions.TagError
        return python_tag, python_tag_close
