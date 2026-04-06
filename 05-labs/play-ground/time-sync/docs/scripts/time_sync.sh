#!/bin/bash
# init_aether.sh

echo "Initializing Project AETHER Structure..."

# 1. Create Core Directories (Explicit Paths to prevent expansion errors)
mkdir -p .github/workflows/

# Apps
mkdir -p apps/web-temple/src/{components,hooks,pages,styles}
mkdir -p apps/web-temple/src/components/{celestial-sphere,archetype-hud,obelisk-countdown}
mkdir -p apps/web-temple/public/assets
mkdir -p apps/api-gateway/{cmd/server,internal/{graph,middleware}}

# Services
mkdir -p services/astrocore/src/{calculations,models}
mkdir -p services/oracle-service/pkg/{archetype,goals}

# Infrastructure
mkdir -p infra/docker
mkdir -p infra/k8s/base
mkdir -p infra/k8s/overlays/{production,staging}
mkdir -p infra/k8s/helm/aether-chart
mkdir -p infra/terraform/modules/{eks-cluster,rds-postgis}

# Libs & Scripts
mkdir -p libs/{math-utils,shared-types}
mkdir -p scripts/

# 2. Touch Files (Workflows)
touch .github/workflows/{ci-astrocore,ci-oracle,deploy-k8s}.yml

# 3. Touch Files (Apps)
touch apps/Dockerfile
touch apps/web-temple/{package.json,next.config.js,tsconfig.json,Dockerfile}
touch apps/web-temple/src/hooks/useTransit.ts
touch apps/web-temple/src/components/celestial-sphere/{Scene.tsx,PlanetMesh.tsx}
touch apps/web-temple/src/components/archetype-hud/{index.tsx,styles.module.css}
touch apps/web-temple/src/components/obelisk-countdown/{index.tsx,utils.ts}
touch apps/web-temple/src/pages/{_app.tsx,index.tsx}
touch apps/api-gateway/{go.mod,go.sum,main.go,Dockerfile}

# 4. Touch Files (Services)
touch services/astrocore/{Cargo.toml,Cargo.lock,src/lib.rs,src/main.rs,Dockerfile}
touch services/astrocore/src/calculations/{ephemeris.rs,mayan.rs,metonic.rs}
touch services/astrocore/src/models/transit.rs
touch services/oracle-service/{main.go,go.mod,go.sum,Dockerfile}
touch services/oracle-service/pkg/archetype/mapping.go
touch services/oracle-service/pkg/goals/countdown.go

# 5. Touch Files (Infra)
touch infra/docker/docker-compose.yml
touch infra/k8s/base/{astrocore-deploy.yaml,oracle-deploy.yaml,postgres-statefulset.yaml,ingress.yaml}
touch infra/k8s/overlays/production/{kustomization.yaml,replicas.yaml}
touch infra/k8s/helm/aether-chart/{Chart.yaml,values.yaml}
touch infra/terraform/{main.tf,variables.tf,outputs.tf}
touch infra/terraform/modules/eks-cluster/main.tf
touch infra/terraform/modules/rds-postgis/main.tf

# 6. Touch Files (Libs & Scripts)
touch libs/math-utils/constants.rs
touch libs/shared-types/{astro.proto,types.ts}
touch scripts/{db-migrate.sh,seed-ephemeris.sh}
touch {.env.example,.gitignore,README.md}

echo "Structure Manifested. Directories Aligned. Ready for Code Injection."