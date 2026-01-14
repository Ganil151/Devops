"""
Solution: Multi-Cloud Factory
"""
from abc import ABC, abstractmethod

class CloudProvider(ABC):
    @abstractmethod
    def create_bucket(self, name):
        pass

class AWSProvider(CloudProvider):
    def create_bucket(self, name):
        return f"AWS: Created S3 Bucket '{name}'"

class AzureProvider(CloudProvider):
    def create_bucket(self, name):
        return f"Azure: Created Storage Container '{name}'"

class CloudFactory:
    @staticmethod
    def get_provider(cloud_name):
        providers = {
            "aws": AWSProvider(),
            "azure": AzureProvider()
        }
        return providers.get(cloud_name.lower())

if __name__ == "__main__":
    factory = CloudFactory()
    p = factory.get_provider("aws")
    if p:
        print(p.create_bucket("my-secure-data"))
