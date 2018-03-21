import sys
import codecs
import io_module


class Filehandler:
    """
        Class used for maintaining creating, storing and managing file hadles.
    """
    def __init__(self, parameters):
        """
            Filehandler constructor.
        :param parameters: dict of the object parameters
        """
        self.params = parameters
        self.print_br = False
        self.input_file = sys.stdin
        self.output_file = sys.stdout
        self.format_file = None
        self.input_set = False
        self.output_set = False
        self.format_set = False

    def __str__(self):
        """
            Called upon str() cast.
            Returns the status of object instance.
        :return: str
        """
        return_str = "Filehandler object:" +\
                     "\nInput file: " + str(self.input_file) +\
                     "\nOutput file: " + str(self.output_file)
        if self.format_set is True:
            return_str += "\nFormat file: " + str(self.format_file)
        else:
            return_str += "\nFormat file not set."
        return return_str

    def get_input_file(self):
        """
            Returns input file set by the handler.
        :return: _io.TextIOWrapper of the input file
        """
        return self.input_file

    def get_output_file(self):
        """
            Returns output file set by the handler.
        :return: _io.TextIOWrapper of the output file
        """
        return self.output_file

    def get_format_file(self):
        """
            Returns format file set by the handler.
        :return: _io.TextIOWrapper of the format file
        """
        return self.format_file

    def get_br_rule(self):
        """
            Returns whether the --br switch was set in the script parameters.
        :return: boolen
        """
        return self.print_br

    def reset_parameters(self, parameters):
        """
            Resets the object and sets new parameters to be used by the object.
            Closes files before assigning new dictionary.
        :param parameters: new dict of parameters to be used by the object
        """
        self.close_files()
        self.params = parameters
        self.print_br = False
        self.input_file = sys.stdin
        self.output_file = sys.stdout
        self.format_file = None
        self.input_set = False
        self.output_set = False
        self.format_set = False

    def open_files(self):
        """
            Opens any files that were set in the script parameters.
            Files that weren't specified are left at their default values.
                (see object constructor)
            Utilises the codecs module.
        :return: integer according to the success of operation
        """
        for parameter in self.params:
            if parameter[2:] == 'input':
                try:
                    self.input_file = codecs.open(self.params[parameter], 'r', 'UTF-8')
                except IOError:
                    io_module.print_err("File error!\nDetail: Cannot open input file.")
                    return 2
                self.input_set = True
            elif parameter[2:] == 'output':
                try:
                    self.output_file = codecs.open(self.params[parameter], 'w+', 'UTF-8')
                except IOError:
                    io_module.print_err("File error!\nDetail: Cannot open or create output file.")
                    return 3
                self.output_set = True
            elif parameter[2:] == 'format':
                try:
                    self.format_file = codecs.open(self.params[parameter], 'r', 'UTF-8')
                    self.format_set = True
                except IOError:
                    self.format_file = None
            elif parameter[2:] == 'br':
                self.print_br = True
        return 0

    def close_files(self):
        """
            Closes any files that were set by the object.
        """
        if self.input_set is True:
            self.input_file.close()
        if self.output_set is True:
            self.output_file.close()
        if self.format_set is True:
            self.format_file.close()
