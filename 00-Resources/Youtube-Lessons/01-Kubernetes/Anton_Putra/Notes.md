/.+/### Amazon EKS networking requirements for VPC and subnets
### On this page

- **Help improve this page**
    
    To contribute to this user guide, choose the **Edit this page on GitHub** link that is located in the right pane of every page.
    
    When you create a cluster, you specify a [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/configure-your-vpc.html) and at least two subnets that are in different Availability Zones. This topic provides an overview of Amazon EKS specific requirements and considerations for the VPC and subnets that you use with your cluster. If you don’t have a VPC to use with Amazon EKS, see [Create an Amazon VPC for your Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html). If you’re creating a local or extended cluster on AWS Outposts, see [Create a VPC and subnets for Amazon EKS clusters on AWS Outposts](https://docs.aws.amazon.com/eks/latest/userguide/eks-outposts-vpc-subnet-requirements.html) instead of this topic. The content in this topic applies for Amazon EKS clusters with hybrid nodes. For additional networking requirements for hybrid nodes, see [Prepare networking for hybrid nodes](https://docs.aws.amazon.com/eks/latest/userguide/hybrid-nodes-networking.html).
    
    ## VPC requirements and considerations
    
    When you create a cluster, the VPC that you specify must meet the following requirements and considerations:
    
    - The VPC must have a sufficient number of IP addresses available for the cluster, any nodes, and other Kubernetes resources that you want to create. If the VPC that you want to use doesn’t have a sufficient number of IP addresses, try to increase the number of available IP addresses.
        
        You can do this by updating the cluster configuration to change which subnets and security groups the cluster uses. You can update from the AWS Management Console, the latest version of the AWS CLI, AWS CloudFormation, and `eksctl` version `v0.164.0-rc.0` or later. You might need to do this to provide subnets with more available IP addresses to successfully upgrade a cluster version.
        
        ###### Important
        
        All subnets that you add must be in the same set of AZs as originally provided when you created the cluster. New subnets must satisfy all of the other requirements, for example they must have sufficient IP addresses.
        
        For example, assume that you made a cluster and specified four subnets. In the order that you specified them, the first subnet is in the `us-west-2a` Availability Zone, the second and third subnets are in `us-west-2b` Availability Zone, and the fourth subnet is in `us-west-2c` Availability Zone. If you want to change the subnets, you must provide at least one subnet in each of the three Availability Zones, and the subnets must be in the same VPC as the original subnets.
        
        If you need more IP addresses than the CIDR blocks in the VPC have, you can add additional CIDR blocks by [associating additional Classless Inter-Domain Routing (CIDR) blocks](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#add-ipv4-cidr) with your VPC. You can associate private (RFC 1918) and public (non-RFC 1918) CIDR blocks to your VPC either before or after you create your cluster.
        
        You can add nodes that use the new CIDR block immediately after you add it. However, because the control plane recognizes the new CIDR block only after the reconciliation is complete, it can take a cluster up to one hour for a CIDR block that you associated with a VPC to be recognized. Then you can run the `kubectl attach`, `kubectl cp`, `kubectl exec`, `kubectl logs`, and `kubectl port-forward` commands (these commands use the `kubelet API`) for nodes and pods in the new CIDR block. Also, if you have Pods that operate as a webhook backend, then you must wait for the control plane reconciliation to complete.
        
    - Avoid IP address range overlaps when you connect your EKS cluster to other VPCs through Transit Gateway, VPC peering, or other networking configurations. CIDR conflicts occur when your EKS cluster’s service CIDR overlaps with the CIDR of a connected VPC. In these scenarios, ServiceIP addresses take priority over resources in connected VPCs with the same IP address, although traffic routing can become unpredictable and applications may fail to connect to intended resources.
        
        To avoid CIDR conflicts, ensure your EKS service CIDR doesn’t overlap with any connected VPC CIDRs and maintain a centralized record of all CIDR assignments. If you encounter CIDR overlaps, you can use a transit gateway with a shared services VPC. For more information, see [Isolated VPCs with shared services](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-isolated-shared.html) and [Amazon EKS VPC routable IP address conservation patterns in a hybrid network](https://aws.amazon.com/blogs/containers/eks-vpc-routable-ip-address-conservation). Also, refer to the Communication across VPCs section of the [VPC and Subnet Considerations](https://docs.aws.amazon.com/eks/latest/best-practices/subnets.html) page in the EKS Best Practices Guide.
        
    - If you want Kubernetes to assign `IPv6` addresses to Pods and services, associate an `IPv6` CIDR block with your VPC. For more information, see [Associate an IPv6 CIDR block with your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-vpcs.html#vpc-associate-ipv6-cidr) in the Amazon VPC User Guide. You cannot use `IPv6` addresses with Pods and services running on hybrid nodes and you cannot use hybrid nodes with clusters configured with the `IPv6` IP address family.
        
    - The VPC must have `DNS` hostname and `DNS` resolution support. Otherwise, nodes can’t register to your cluster. For more information, see [DNS attributes for your VPC](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html) in the Amazon VPC User Guide.
        
    - The VPC might require VPC endpoints using AWS PrivateLink. For more information, see [Subnet requirements and considerations](https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html#network-requirements-subnets).
        
    
    If you created a cluster with Kubernetes `1.14` or earlier, Amazon EKS added the following tag to your VPC:
    
    |Key|Value|
    |:--|:--|
    |`` kubernetes.io/cluster/`my-cluster` ``|`owned`|
    
    This tag was only used by Amazon EKS. You can remove the tag without impacting your services. It’s not used with clusters that are version `1.15` or later.
    
    ## Subnet requirements and considerations
    
    When you create a cluster, Amazon EKS creates 2–4 [elastic network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html) in the subnets that you specify. These network interfaces enable communication between your cluster and your VPC. These network interfaces also enable Kubernetes features that use the `kubelet API`. The connections to the `kubelet` API are used in the `kubectl attach`, `kubectl cp`, `kubectl exec`, `kubectl logs`, and `kubectl port-forward` commands. Each Amazon EKS created network interface has the text `` Amazon EKS `cluster-name` `` in its description.
    
    Amazon EKS can create its network interfaces in any subnet that you specify when you create a cluster. You can change which subnets Amazon EKS creates its network interfaces in after your cluster is created. When you update the Kubernetes version of a cluster, Amazon EKS deletes the original network interfaces that it created, and creates new network interfaces. These network interfaces might be created in the same subnets as the original network interfaces or in different subnets than the original network interfaces. To control which subnets network interfaces are created in, you can limit the number of subnets you specify to only two when you create a cluster or update the subnets after creating the cluster.
    
    ### Subnet requirements for clusters
    
    The [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html#subnet-types) that you specify when you create or update a cluster must meet the following requirements:
    
    - The subnets must each have at least six IP addresses for use by Amazon EKS. However, we recommend at least 16 IP addresses.
        
    - The subnets must be in at least two different Availability Zones.
        
    - The subnets can’t reside in AWS Outposts or AWS Wavelength. However, if you have them in your VPC, you can deploy self-managed nodes and Kubernetes resources to these types of subnets. For more information about self-managed nodes, see [Maintain nodes yourself with self-managed nodes](https://docs.aws.amazon.com/eks/latest/userguide/worker.html).
        
    - The subnets can be a public or private. However, we recommend that you specify private subnets, if possible. A public subnet is a subnet with a route table that includes a route to an [internet gateway](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Internet_Gateway.html), whereas a private subnet is a subnet with a route table that doesn’t include a route to an internet gateway.
        
    - The subnets can’t reside in the following Availability Zones:
        
        |AWS Region|Region name|Disallowed Availability Zone IDs|
        |:--|:--|:--|
        |`us-east-1`|US East (N. Virginia)|`use1-az3`|
        |`us-west-1`|US West (N. California)|`usw1-az2`|
        |`ca-central-1`|Canada (Central)|`cac1-az3`|
        
    
    ### IP address family usage by component
    
    The following table contains the IP address family used by each component of Amazon EKS. You can use a network address translation (NAT) or other compatibility system to connect to these components from source IP addresses in families with the "No" value for a table entry.
    
    Functionality can differ depending on the IP family (`ipFamily`) setting of the cluster. This setting changes the type of IP addresses used for the CIDR block that Kubernetes assigns to Services. A cluster with the setting value of IPv4 is referred to as an _IPv4 cluster_, and a cluster with the setting value of IPv6 is referred to as an _IPv6 cluster_.
    
    |Component|IPv4 addresses|IPv6 addresses|Dual stack addresses|
    |:--|:--|:--|:--|
    |EKS API public endpoint|Yes1,3|Yes1,3|Yes1,3|
    |EKS API VPC endpoint|Yes|No|No|
    |EKS Auth API public endpoint (EKS Pod Identity)|Yes1|Yes1|Yes1|
    |EKS Auth API VPC endpoint (EKS Pod Identity)|Yes1|Yes1|Yes1|
    |`IPv4` Kubernetes cluster public endpoint2|Yes|No|No|
    |`IPv4` Kubernetes cluster private endpoint2|Yes|No|No|
    |`IPv6` Kubernetes cluster public endpoint2|Yes1,4|Yes1,4|Yes4|
    |`IPv6` Kubernetes cluster private endpoint2|Yes1,4|Yes1,4|Yes4|
    |Kubernetes cluster subnets|Yes2|No|Yes2|
    |Node Primary IP addresses|Yes2|No|Yes2|
    |Cluster CIDR range for Service IP addresses|Yes2|Yes2|No|
    |Pod IP addresses from the VPC CNI|Yes2|Yes2|No|
    |IRSA OIDC Issuer URLs|Yes1,3|Yes1,3|Yes1,3|
    
    ###### Note
    
    1 The endpoint is dual stack with both `IPv4` and `IPv6` addresses. Your applications outside of AWS, your nodes for the cluster, and your pods inside the cluster can reach this endpoint by either `IPv4` or `IPv6`.
    
    2 You choose between an `IPv4` cluster and `IPv6` cluster in the IP family (`ipFamily`) setting of the cluster when you create a cluster and this can’t be changed. Instead, you must choose a different setting when you create another cluster and migrate your workloads.
    
    3 The dual-stack endpoint was introduced in August 2024. To use the dual-stack endpoints with the AWS CLI, see the [Dual-stack and FIPS endpoints](https://docs.aws.amazon.com/sdkref/latest/guide/feature-endpoints.html) configuration in the _AWS SDKs and Tools Reference Guide_. The following lists the new endpoints:
    
    **EKS API public endpoint**
    
    ``eks.`region`.api.aws``
    
    **IRSA OIDC Issuer URLs**
    
    ``oidc-eks.`region`.api.aws``
    
    4 The dual-stack cluster endpoint was introduced in October 2024. EKS creates the following endpoint for new clusters that are made after this date and that select `IPv6` in the IP family (ipFamily) setting of the cluster:
    
    **EKS cluster public/private endpoint**
    
    ``eks-cluster.`region`.api.aws``
    
    ### Subnet requirements for nodes
    
    You can deploy nodes and Kubernetes resources to the same subnets that you specify when you create your cluster. However, this isn’t necessary. This is because you can also deploy nodes and Kubernetes resources to subnets that you didn’t specify when you created the cluster. If you deploy nodes to different subnets, Amazon EKS doesn’t create cluster network interfaces in those subnets. Any subnet that you deploy nodes and Kubernetes resources to must meet the following requirements:
    
    - The subnets must have enough available IP addresses to deploy all of your nodes and Kubernetes resources to.
        
    - If you want Kubernetes to assign `IPv6` addresses to Pods and services, then you must have one `IPv6` CIDR block and one `IPv4` CIDR block that are associated with your subnet. For more information, see [Associate an IPv6 CIDR block with your subnet](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-subnets.html#subnet-associate-ipv6-cidr) in the Amazon VPC User Guide. The route tables that are associated with the subnets must include routes to `IPv4` and `IPv6` addresses. For more information, see [Routes](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Route_Tables.html#route-table-routes) in the Amazon VPC User Guide. Pods are assigned only an `IPv6` address. However the network interfaces that Amazon EKS creates for your cluster and your nodes are assigned an `IPv4` and an `IPv6` address.
        
    - If you need inbound access from the internet to your Pods, make sure to have at least one public subnet with enough available IP addresses to deploy load balancers and ingresses to. You can deploy load balancers to public subnets. Load balancers can load balance to Pods in private or public subnets. We recommend deploying your nodes to private subnets, if possible.
        
    - If you plan to deploy nodes to a public subnet, the subnet must auto-assign `IPv4` public addresses or `IPv6` addresses. If you deploy nodes to a private subnet that has an associated `IPv6` CIDR block, the private subnet must also auto-assign `IPv6` addresses. If you used the AWS CloudFormation template provided by Amazon EKS to deploy your VPC after March 26, 2020, this setting is enabled. If you used the templates to deploy your VPC before this date or you use your own VPC, you must enable this setting manually. For the template, see [Create an Amazon VPC for your Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html). For more information, see [Modify the public IPv4 addressing attribute for your subnet](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-subnets.html#subnet-public-ip) and [Modify the IPv6 addressing attribute for your subnet](https://docs.aws.amazon.com/vpc/latest/userguide/working-with-subnets.html#subnet-ipv6) in the [Amazon VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/).
        
    - If the subnet that you deploy a node to is a private subnet and its route table doesn’t include a route to a network address translation [(NAT) device](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat.html) (`IPv4`) or an [egress-only gateway](https://docs.aws.amazon.com/vpc/latest/userguide/egress-only-internet-gateway.html) (`IPv6`), add VPC endpoints using AWS PrivateLink to your VPC. VPC endpoints are needed for all the AWS services that your nodes and Pods need to communicate with. Examples include Amazon ECR, Elastic Load Balancing, Amazon CloudWatch, AWS Security Token Service, and Amazon Simple Storage Service (Amazon S3). The endpoint must include the subnet that the nodes are in. Not all AWS services support VPC endpoints. For more information, see [What is AWS PrivateLink?](https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html) and [AWS services that integrate with AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html). For a list of more Amazon EKS requirements, see [Deploy private clusters with limited internet access](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html).
        
    - If you want to deploy load balancers to a subnet, the subnet must have the following tag:
        
        - Private subnets
            
            |Key|Value|
            |:--|:--|
            |`kubernetes.io/role/internal-elb`|`1`|
            
        - Public subnets
            
            |Key|Value|
            |:--|:--|
            |`kubernetes.io/role/elb`|`1`|
            
        
    
    When a Kubernetes cluster that’s version `1.18` and earlier was created, Amazon EKS added the following tag to all of the subnets that were specified.
    
    |Key|Value|
    |:--|:--|
    |`` kubernetes.io/cluster/`my-cluster` ``|`shared`|
    
    When you create a new Kubernetes cluster now, Amazon EKS doesn’t add the tag to your subnets. If the tag was on subnets that were used by a cluster that was previously a version earlier than `1.19`, the tag wasn’t automatically removed from the subnets when the cluster was updated to a newer version. Version `2.1.1` or earlier of the AWS Load Balancer Controller requires this tag. If you are using a newer version of the Load Balancer Controller, you can remove the tag without interrupting your services. For more information about the controller, see [Route internet traffic with AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html).
    
    If you deployed a VPC by using `eksctl` or any of the Amazon EKS AWS CloudFormation VPC templates, the following applies:
    
    - **On or after March 26, 2020** – Public `IPv4` addresses are automatically assigned by public subnets to new nodes that are deployed to public subnets.
        
    - **Before March 26, 2020** – Public `IPv4` addresses aren’t automatically assigned by public subnets to new nodes that are deployed to public subnets.
        
    
    This change impacts new node groups that are deployed to public subnets in the following ways:
    
    - **[Managed node groups](https://docs.aws.amazon.com/eks/latest/userguide/create-managed-node-group.html)** – If the node group is deployed to a public subnet on or after April 22, 2020, automatic assignment of public IP addresses must be enabled for the public subnet. For more information, see [Modifying the public IPv4 addressing attribute for your subnet](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#subnet-public-ip).
        
    - **[Linux](https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html), [Windows](https://docs.aws.amazon.com/eks/latest/userguide/launch-windows-workers.html), or [Arm](https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html#arm-ami) self-managed node groups** – If the node group is deployed to a public subnet on or after March 26, 2020, automatic assignment of public IP addresses must be enabled for the public subnet. Otherwise, the nodes must be launched with a public IP address instead. For more information, see [Modifying the public IPv4 addressing attribute for your subnet](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#subnet-public-ip) or [Assigning a public IPv4 address during instance launch](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#vpc-public-ip).
        
    
    ## Shared subnet requirements and considerations
    
    You can use _VPC sharing_ to share subnets with other AWS accounts within the same AWS Organizations. You can create Amazon EKS clusters in shared subnets, with the following considerations:
    
    - The owner of the VPC subnet must share a subnet with a participant account before that account can create an Amazon EKS cluster in it.
        
    - You can’t launch resources using the default security group for the VPC because it belongs to the owner. Additionally, participants can’t launch resources using security groups that are owned by other participants or the owner.
        
    - In a shared subnet, the participant and the owner separately controls the security groups within each respective account. The subnet owner can see security groups that are created by the participants but cannot perform any actions on them. If the subnet owner wants to remove or modify these security groups, the participant that created the security group must take the action.
        
    - If a cluster is created by a participant, the following considerations apply:
        
        - Cluster IAM role and Node IAM roles must be created in that account. For more information, see [Amazon EKS cluster IAM role](https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html) and [Amazon EKS node IAM role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html).
            
        - All nodes must be made by the same participant, including managed node groups.
            
        
    - The shared VPC owner cannot view, update or delete a cluster that a participant creates in the shared subnet. This is in addition to the VPC resources that each account has different access to. For more information, see [Responsibilities and permissions for owners and participants](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-sharing.html#vpc-share-limitations) in the _Amazon VPC User Guide_.
        
    - If you use the _custom networking_ feature of the Amazon VPC CNI plugin for Kubernetes, you need to use the Availability Zone ID mappings listed in the owner account to create each `ENIConfig`. For more information, see [Deploy Pods in alternate subnets with custom networking](https://docs.aws.amazon.com/eks/latest/userguide/cni-custom-network.html).