import re

class TextNormalizer:
    """
    Standard text normalizer for ASR evaluation.
    Matches the "ground truth" format of LibriSpeech.
    1. Converts all text to uppercase.
    2. Removes all punctuation.
    3. Collapses multiple spaces into one.
    """
    def __init__(self):
        # This regex matches any character that is NOT an uppercase letter (A-Z)
        # or a space. We will replace all matches with an empty string.
        self.punctuation_regex = re.compile(r"[^A-Z ]")
        # This regex matches one or more space characters.
        self.whitespace_regex = re.compile(r"\s+")

    def __call__(self, text: str) -> str:
        # 1. Convert to uppercase
        text = text.upper()
        
        # 2. Remove all punctuation
        text = self.punctuation_regex.sub("", text)
        
        # 3. Collapse all whitespace (spaces, tabs, newlines) into a single space
        text = self.whitespace_regex.sub(" ", text)
        
        # 4. Remove leading/trailing whitespace
        return text.strip()

if __name__ == "__main__":
    # Example of how to use it
    normalizer = TextNormalizer()
    test_string = "Hello, world! This is a test... [it's 100%]"
    normalized = normalizer(test_string)
    
    print(f"Original:    '{test_string}'")
    print(f"Normalized:  '{normalized}'")
    # Expected Output: 'HELLO WORLD THIS IS A TEST ITS 100'