
After successfull creating the cluster, spin up a ec2 instance and install aws cli and kubectl and run the bash script EKS-TF/scripts/setup.sh to install kubectl and aws cli 

Bootstrap EKS cluster by runinning this aws code:
aws eks update-kubeconfig --name dev-ap-medium-eks-cluster

then run:
kubectl get nodes

