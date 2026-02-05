"""
Solution: Dynamic Plugin Loader
"""
import os
import importlib.util
import inspect
from abc import ABC, abstractmethod

class BaseTask(ABC):
    @abstractmethod
    def execute(self):
        pass

def load_plugins(directory):
    registry = []
    if not os.path.exists(directory):
        return registry

    for filename in os.listdir(directory):
        if filename.endswith(".py") and filename != "__init__.py":
            module_name = filename[:-3]
            file_path = os.path.join(directory, filename)
            
            # Dynamic Import Logic
            spec = importlib.util.spec_from_file_location(module_name, file_path)
            module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(module)
            
            # Discovery Logic
            for name, obj in inspect.getmembers(module):
                if inspect.isclass(obj) and issubclass(obj, BaseTask) and obj is not BaseTask:
                    registry.append(obj())
                    
    return registry

if __name__ == "__main__":
    pass
