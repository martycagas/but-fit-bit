class RegexError(Exception):
    """
        Represents exception thrown when Formatparser encounters an unknown regex.
    """
    pass


class TagError(Exception):
    """
        Represents exception thrown when Formatparser encounters an unknown format tag.
    """
    pass
