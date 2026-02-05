import boto3
import json
from datetime import datetime, timedelta
import logging

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

class CostOptimizer:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.region = region

    def find_orphaned_ebs_volumes(self):
        """Find EBS volumes that are not attached to any instance."""
        logger.info(f"Checking for orphaned EBS volumes in {self.region}...")
        
        paginator = self.ec2.get_paginator('describe_volumes')
        orphaned_volumes = []
        
        # Filter for 'available' volumes (means they are not 'in-use')
        page_iterator = paginator.paginate(
            Filters=[{'Name': 'status', 'Values': ['available']}]
        )
        
        total_wasted_gb = 0
        for page in page_iterator:
            for vol in page['Volumes']:
                vol_id = vol['VolumeId']
                size = vol['Size']
                total_wasted_gb += size
                orphaned_volumes.append({
                    'VolumeId': vol_id,
                    'SizeGB': size,
                    'State': vol['State']
                })
                logger.warning(f"Found orphaned volume: {vol_id} ({size}GB)")
        
        # Calculate potential savings ($0.10 per GB-month)
        monthly_savings = total_wasted_gb * 0.10
        logger.info(f"Total potential savings from EBS: ${monthly_savings:.2f}/month")
        return orphaned_volumes

    def check_unattached_eips(self):
        """Find Elastic IPs not associated with any instance."""
        logger.info(f"Checking for unattached Elastic IPs in {self.region}...")
        
        addresses = self.ec2.describe_addresses()
        unattached_eips = []
        
        for addr in addresses['Addresses']:
            if 'InstanceId' not in addr and 'AssociationId' not in addr:
                public_ip = addr['PublicIp']
                unattached_eips.append(public_ip)
                logger.warning(f"Found unattached EIP: {public_ip}")
        
        # Calculate potential savings ($0.005 per hour = ~$3.60/month)
        monthly_savings = len(unattached_eips) * 3.60
        logger.info(f"Total potential savings from EIPs: ${monthly_savings:.2f}/month")
        return unattached_eips

    def tag_for_cleanup(self, resource_ids, tag_key="CleanupAction", tag_value="Delete"):
        """Tag identified resources for manual review or future deletion."""
        if not resource_ids:
            return
            
        logger.info(f"Tagging {len(resource_ids)} resources with {tag_key}={tag_value}...")
        try:
            self.ec2.create_tags(
                Resources=resource_ids,
                Tags=[
                    {'Key': tag_key, 'Value': tag_value},
                    {'Key': 'AutoCleanupDate', 'Value': (datetime.now() + timedelta(days=7)).strftime('%Y-%m-%%d')}
                ]
            )
            logger.info("Successfully tagged resources.")
        except Exception as e:
            logger.error(f"Failed to tag resources: {e}")

def main():
    optimizer = CostOptimizer()
    
    # 1. Audit Volumes
    vols = optimizer.find_orphaned_ebs_volumes()
    vol_ids = [v['VolumeId'] for v in vols]
    
    # 2. Audit EIPs (EIPs don't have standard VolumeId style IDs in describe_addresses, 
    # but they have AllocationId for VPC EIPs)
    # For simplicity, we'll just log them in this example.
    eips = optimizer.check_unattached_eips()
    
    # 3. Tag orphan volumes for deletion (Safety First: Don't delete yet!)
    optimizer.tag_for_cleanup(vol_ids)

if __name__ == "__main__":
    main()
