#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ENV=${1:-dev}

echo -e "${BLUE}🧪 Running Health Checks${NC}"
echo -e "${BLUE}Environment: ${ENV}${NC}"
echo ""

# Check prerequisites
command -v kubectl >/dev/null 2>&1 || { echo -e "${RED}❌ kubectl not found${NC}"; exit 1; }
command -v curl >/dev/null 2>&1 || { echo -e "${RED}❌ curl not found${NC}"; exit 1; }

# Get cluster context
CONTEXT=$(kubectl config current-context)
echo -e "${YELLOW}📍 Current context: ${CONTEXT}${NC}"
echo ""

# Test 1: Node Health
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test 1: Node Health${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if kubectl get nodes | grep -q "Ready"; then
  echo -e "${GREEN}✅ Nodes are healthy${NC}"
  kubectl get nodes
else
  echo -e "${RED}❌ Nodes are not ready${NC}"
  kubectl get nodes
  exit 1
fi

echo ""

# Test 2: Pod Status
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test 2: Pod Status (petclinic namespace)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if kubectl get namespace petclinic >/dev/null 2>&1; then
  PODS=$(kubectl get pods -n petclinic --no-headers 2>/dev/null | wc -l)
  RUNNING=$(kubectl get pods -n petclinic --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
  
  echo -e "Total Pods: ${PODS}"
  echo -e "Running Pods: ${RUNNING}"
  
  if [ "$RUNNING" -eq "$PODS" ] && [ "$PODS" -gt 0 ]; then
    echo -e "${GREEN}✅ All pods are running${NC}"
  else
    echo -e "${YELLOW}⚠️  Some pods are not running${NC}"
    kubectl get pods -n petclinic
  fi
else
  echo -e "${YELLOW}⚠️  Namespace 'petclinic' not found. Has the application been deployed?${NC}"
fi

echo ""

# Test 3: Service Endpoints
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test 3: Service Endpoints${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if kubectl get svc -n petclinic >/dev/null 2>&1; then
  kubectl get svc -n petclinic
  
  # Try to get LoadBalancer URL
  LB_URL=$(kubectl get svc api-gateway -n petclinic -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
  
  if [ -n "$LB_URL" ]; then
    echo ""
    echo -e "${GREEN}✅ LoadBalancer URL: http://${LB_URL}${NC}"
    echo -e "${YELLOW}Testing health endpoint...${NC}"
    
    sleep 5 # Wait for DNS propagation
    
    if curl -sf "http://${LB_URL}/actuator/health" >/dev/null 2>&1; then
      echo -e "${GREEN}✅ Health endpoint is responding${NC}"
    else
      echo -e "${YELLOW}⚠️  Health endpoint not responding yet (may need time to warm up)${NC}"
    fi
  else
    echo -e "${YELLOW}⚠️  LoadBalancer not yet provisioned${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  No services found in petclinic namespace${NC}"
fi

echo ""

# Test 4: RDS Connectivity
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Test 4: RDS Connectivity${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cd "$(dirname "$0")/../terraform/environments/${ENV}" || exit 1
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null || echo "")

if [ -n "$RDS_ENDPOINT" ]; then
  echo -e "RDS Endpoint: ${RDS_ENDPOINT}"
  
  # Test connectivity from a pod
  if kubectl get pods -n petclinic --no-headers 2>/dev/null | grep -q "Running"; then
    POD_NAME=$(kubectl get pods -n petclinic --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    
    if [ -n "$POD_NAME" ]; then
      echo -e "${YELLOW}Testing RDS connectivity from pod ${POD_NAME}...${NC}"
      
      if kubectl exec -n petclinic "$POD_NAME" -- nc -zv "$RDS_ENDPOINT" 3306 2>&1 | grep -q "succeeded"; then
        echo -e "${GREEN}✅ RDS is reachable from pods${NC}"
      else
        echo -e "${RED}❌ RDS is not reachable from pods${NC}"
      fi
    fi
  else
    echo -e "${YELLOW}⚠️  No running pods to test RDS connectivity${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  RDS endpoint not found in Terraform outputs${NC}"
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🏁 Health Check Complete${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
