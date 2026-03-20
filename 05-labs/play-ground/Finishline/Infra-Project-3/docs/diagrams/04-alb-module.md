# ALB Module Diagram

## Module: terraform/modules/alb

```mermaid
flowchart TB
    subgraph ALB_Module["ALB Module"]

        subgraph SecurityGroup["Security Group"]
            SG["aws_security_group<br/>alb_sg"]

            IngressHTTP["ingress<br/>HTTP (80)<br/>0.0.0.0/0"]
            IngressHTTPS["ingress<br/>HTTPS (443)<br/>0.0.0.0/0"]
            Egress["egress<br/>All Traffic<br/>0.0.0.0/0"]
        end

        subgraph LoadBalancer["Application Load Balancer"]
            ALB["aws_lb<br/>finishline_alb"]
        end

        subgraph TargetGroup["Target Group"]
            TG["aws_lb_target_group<br/>eks_target_group"]

            HealthCheck["health_check<br/>enabled: true<br/>path: /<br/>interval: 30s<br/>timeout: 5s"]
        end

        subgraph Listeners["Listeners"]
            HTTPListener["aws_lb_listener<br/>http (port 80)"]
            HTTPSListener["aws_lb_listener<br/>https (port 443)"]
        end

        subgraph Inputs["Input Variables"]
            vpc_id["var.vpc_id"]
            public_subnet_ids["var.public_subnet_ids"]
            environment["var.environment"]
            acm_cert["var.acm_certificate_arn"]
        end

        subgraph Outputs["Output Values"]
            alb_arn["alb_arn"]
            alb_dns["alb_dns_name"]
            alb_zone["alb_zone_id"]
            target_group_arn["target_group_arn"]
        end
    end

    Internet["Internet"]
    EKS["EKS Cluster<br/>Kubernetes Services"]

    SG --> IngressHTTP
    SG --> IngressHTTPS
    SG --> Egress

    ALB --> SG
    ALB -->|security_groups| public_subnet_ids

    TG --> HealthCheck

    HTTPListener --> ALB
    HTTPSListener --> ALB

    HTTPListener -->|dev: forward<br/>prod: redirect| TG
    HTTPSListener -->|forward| TG

    Internet --> ALB
    ALB --> EKS
```

---

## ALB Architecture

```mermaid
flowchart TB
    subgraph AWS["AWS Cloud"]

        subgraph PublicSubnets["Public Subnets"]
            PS1["Public Subnet 1<br/>AZ 1"]
            PS2["Public Subnet 2<br/>AZ 2"]
            PS3["Public Subnet 3<br/>AZ 3"]
        end

        subgraph ALB_Components["Application Load Balancer"]
            ALB_Icon["🔷 ALB<br/>finishline-alb"]

            subgraph SecurityGroup["Security Group"]
                SG_Rules["Inbound: 80, 443 (HTTP/S)<br/>Outbound: All"]
            end

            subgraph Listeners_ALB["Listeners"]
                HTTP_Listener["👂 HTTP :80"]
                HTTPS_Listener["👂 HTTPS :443"]
            end

            subgraph Rules["Rules"]
                Rule_Dev["dev: Forward to TG"]
                Rule_Prod["prod: Redirect → HTTPS"]
            end

            subgraph TG_ALB["Target Group"]
                TG_EKS["eks-target-group<br/>Port: 80<br/>Protocol: HTTP"]
            end
        end

        subgraph EKS_Services["EKS Cluster"]
            K8s_Service1["Service A"]
            K8s_Service2["Service B"]
            Pod1["Pod 1"]
            Pod2["Pod 2"]
            Pod3["Pod 3"]
        end

    end

    Users["👥 Users<br/>Internet Traffic"]
    Apps["📱 Applications<br/>API Calls"]

    Users -->|HTTP/HTTPS| ALB_Icon
    Apps -->|HTTP/HTTPS| ALB_Icon

    ALB_Icon --> HTTP_Listener
    ALB_Icon --> HTTPS_Listener

    HTTP_Listener --> Rule_Dev
    HTTP_Listener --> Rule_Prod
    HTTPS_Listener --> Rule_Dev

    Rule_Dev --> TG_EKS
    Rule_Prod --> HTTPS_Listener

    TG_EKS --> PS1
    TG_EKS --> PS2
    TG_EKS --> PS3

    PS1 --> K8s_Service1
    K8s_Service1 --> Pod1
    K8s_Service1 --> Pod2
    K8s_Service1 --> Pod3
```

---

## Traffic Flow

```mermaid
sequenceDiagram
    participant User as User
    participant ALB as ALB (port 80/443)
    participant TG as Target Group
    participant EKS as EKS Pods

    alt Development Environment
        User->>ALB: HTTP Request (port 80)
        ALB->>TG: Forward to Target Group
        TG->>EKS: Route to healthy pod
        EKS->>TG: HTTP Response
        TG->>ALB: Response
        ALB->>User: HTTP Response
    else Production Environment
        User->>ALB: HTTP Request (port 80)
        ALB->>ALB: Redirect to HTTPS (301)
        User->>ALB: HTTPS Request (port 443)
        ALB->>TG: Forward to Target Group
        TG->>EKS: Route to healthy pod
        EKS->>TG: HTTP Response
        TG->>ALB: Response
        ALB->>User: HTTPS Response
    end
```

---

## Ingress to Pod Traffic Flow (Assignment §61, §62)

```mermaid
flowchart LR
    subgraph Internet_Zone["🌐 Internet Zone"]
        Client["👤 Client<br/>Browser/App"]
    end

    subgraph VPC_Public["📦 VPC - Public Subnets (AZ 1,2,3)"]
        subgraph ALB_Zone["🔷 Shared ALB (group-tag: finishline)"]
            ALB_DNS["finishline-alb-*.elb.amazonaws.com"]
            Listener80["👂 :80"]
            Listener443["👂 :443"]
            TargetGroup["🎯 Target Group<br/>port: 80"]
        end
    end

    subgraph VPC_Private["📦 VPC - Private Subnets (AZ 1,2,3)"]
        subgraph EKS_Cluster["☸️ EKS Cluster"]
            subgraph Ingress_Zone["🎫 Kubernetes Ingress
            (group: finishline)"]
                Ingress["aws-load-balancer-controller
                Ingress resource"]
                IngressRule["Host: *.finishline.com
                Path: /api → svc:api"]
            end

            subgraph Services["🔌 Kubernetes Services"]
                APIService["svc:api
                ClusterIP: 10.x.x.x"]
                WebService["svc:web
                ClusterIP: 10.x.x.x"]
            end

            subgraph Pods["🖥️ Pods"]
                APIPod["api-pod
                :8080"]
                WebPod["web-pod
                :8080"]
            end
        end
    end

    Client --HTTP/HTTPS--> ALB_DNS
    ALB_DNS --> Listener80
    ALB_DNS --> Listener443
    Listener80 --> TargetGroup
    Listener443 --> TargetGroup
    TargetGroup -->|Route to pod| Ingress
    Ingress --> IngressRule
    IngressRule --> APIService
    IngressRule --> WebService
    APIService --> APIPod
    WebService --> WebPod
```

---

## Key Features

| Feature                | Implementation                              | Reference |
| ---------------------- | ------------------------------------------- | --------- |
| **Load Balancer Type** | Application Load Balancer (layer 7)         | §31       |
| **Group Tag**          | `group-tag = "finishline"` for IngressGroup | §62, §65  |
| **Internet-facing**    | `internal = false`                          | §62       |
| **HTTP Listener**      | Port 80, redirects to HTTPS in prod         | §62       |
| **HTTPS Listener**     | Port 443 with ACM certificate (optional)    | §62       |
| **Target Group**       | HTTP port 80, health check on /             | §62       |
| **Security Groups**    | Allow HTTP/HTTPS from 0.0.0.0/0             | §31       |

---

## Listener Configuration

```mermaid
flowchart LR
    subgraph HTTP_Port80["HTTP Listener (80)"]
        if Dev["Environment?"]
        forward["Forward to<br/>Target Group"]
        redirect["Redirect to<br/>HTTPS :443"]
    end

    subgraph HTTPS_Port443["HTTPS Listener (443)"]
        forward_https["Forward to<br/>Target Group"]
    end

    if Dev -->|dev| forward
    if Dev -->|staging/prod| redirect
    redirect --> HTTPS_Port443
    HTTPS_Port443 --> forward_https
```

---

## Health Check Configuration

```mermaid
flowchart TB
    subgraph HealthCheck["Health Check Configuration"]
        HC_Enabled["enabled: true"]
        HC_Threshold["healthy_threshold: 2<br/>unhealthy_threshold: 2"]
        HC_Interval["interval: 30 seconds"]
        HC_Timeout["timeout: 5 seconds"]
        HC_Matcher["matcher: 200-399"]
        HC_Path["path: /"]
        HC_Protocol["protocol: HTTP<br/>port: traffic-port"]
    end

    HealthCheck --> ALB
```

---

_Generated from: terraform/modules/alb/main.tf_
