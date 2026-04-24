"""
Challenge: Multi-Cloud Factory
Scenario: You want a single command `provision --cloud aws` or `--cloud azure`.
The main logic should not care which cloud it is.

TODO:
1. Define a `CloudProvider` Abstract Base Class with an abstract `create_bucket(name)` method.
2. Implement `AWSProvider` and `AzureProvider` inheriting from `CloudProvider`.
3. Create a `CloudFactory` that returns the correct provider instance.
4. Implement a `main()` function that takes a cloud name and uses the factory to provision a "test-bucket".
"""
from abc import ABC, abstractmethod

class CloudProvider(ABC):
    # --- START YOUR CODE HERE ---
    pass

# Implement AWSProvider
# Implement AzureProvider
# Implement CloudFactory

if __name__ == "__main__":
    # Test your factory
    pass
