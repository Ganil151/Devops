"""
Challenge: Dynamic Plugin Loader
Scenario: You are building a framework. You want to drop new .py files 
into a folder and have the framework automatically "discover" them.

TODO:
1. Create a `BaseTask` ABC with an `execute()` method.
2. Use `importlib` and `os.listdir` to find all .py files in a given directory.
3. Import the modules dynamically.
4. If a class in the module is a subclass of `BaseTask` (and not the base itself), 
   instantiate it and add it to a `registry` list.
5. Loop through the `registry` and run `.execute()` on each.
"""
import os
import importlib
import inspect
from abc import ABC, abstractmethod

class BaseTask(ABC):
    @abstractmethod
    def execute(self):
        pass

def load_plugins(directory):
    registry = []
    # --- START YOUR CODE HERE ---
    return registry

if __name__ == "__main__":
    # Test loading
    pass
