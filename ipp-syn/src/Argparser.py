import getopt
import io_module


class Argparser:
    """
        Class used for managing, parsing and validating script arguments.
    """
    def __init__(self, parameters, options):
        """
            Argparser constructor.
        :param parameters: list of parser parameters
        :param options: list of parser options
        """
        self.input_params = parameters
        self.input_opts = options
        self.arg_dict = {}

    def __str__(self):
        """
            Called upon str() cast.
            Returns the status of object instance.
        :return: str
        """
        return "Argparser object:" +\
               "\nInputted parameters: " + str(self.input_params) +\
               "\nInputted options: " + str(self.input_opts) +\
               "\nParsed argument dictionary: " + str(self.arg_dict)

    def get_options(self):
        """
            Returns list of options used by the object.
        :return: list
        """
        return self.input_opts

    def get_args(self):
        """
            Returns dictionary that is the result of parsing.
        :return: dict
        """
        return self.arg_dict

    def set_parameters(self, parameters):
        """
            Sets new parameters for the object.
        :param parameters: list of parser parameters
        """
        self.input_params = parameters

    def set_options(self, options):
        """
            Sets new options for the object.
        :param options: list of parser options
        """
        self.input_opts = options

    def parse_args(self):
        """
            Parses parameters based on inputed options.
            Utilises the getopts module.
        :return: integer according to the success of operation
        """
        try:
            args = getopt.getopt(self.input_params, '', self.input_opts)
        except getopt.GetoptError as exception:
            io_module.print_err(exception)
            return 1
        for arg, val in args[0]:
            self.arg_dict[arg] = val
        return 0

    def validate_args(self):
        """
            Validates the parameters, such as checking if all entered parameters are valid.
            If --help was inputed, checks whether it was the only parameters entered and prints out help.
        :return: integer according to the success of operation
        """
        if '--help' in self.arg_dict:
            if len(self.input_params) > 1:
                io_module.print_err("Invalid format of parameters!\nDetail: --help doesn't allow any other parameters.")
                return 1
            else:
                io_module.print_help()
                return 101
        for parameter in self.arg_dict:
            if parameter[2:] in self.input_opts or parameter[2:] + '=' in self.input_opts:
                pass
            else:
                io_module.print_err("Invalid format of parameters!\nDetail: Unexpected parameter.")
                return 1
        return 0
