# Kubernetes Practice Project

Spring Boot + Next.js + PostgreSQL 기반 Kubernetes 연습 프로젝트

## 구성 요소

| 컴포넌트 | 설명 | 포트 |
|---------|------|------|
| Spring Boot | REST API 서버 (Gradle, JPA) | 8080 |
| Next.js | 프론트엔드 (App Router) | 3000 |
| Nginx | Next.js 사이드카 리버스 프록시 | 80 |
| PostgreSQL | 데이터베이스 | 5432 |
| Elasticsearch | 로그 저장소 | 9200 |
| Kibana | 로그 시각화 | 5601 |
| Filebeat | 로그 수집 (DaemonSet) | - |
| Prometheus | 메트릭 수집 | 9090 |
| Grafana | 메트릭 시각화 | 3000 |

## 아키텍처

```
                    ┌─────────────┐
                    │   Ingress   │
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           │               │               │
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │  Next.js    │ │  Spring     │ │  Monitoring │
    │  + Nginx    │ │  Boot       │ │  Stack      │
    │  (replica 3)│ │  (replica 3)│ │             │
    └──────┬──────┘ └──────┬──────┘ └─────────────┘
           │               │
           │               ▼
           │        ┌─────────────┐
           └───────▶│  PostgreSQL │
                    └─────────────┘
```

## 사전 요구사항

- Docker Desktop with Kubernetes enabled
- kubectl
- Helm 3.x (Helm 배포 시)
- Ingress Controller (NGINX)

```bash
# Ingress Controller 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

## 프로젝트 구조

```
practice/
├── spring-app/              # Spring Boot 소스코드
│   ├── src/
│   ├── build.gradle
│   └── Dockerfile
├── next-app/                # Next.js 소스코드
│   ├── app/
│   ├── package.json
│   └── Dockerfile
├── k8s/                     # Raw Kubernetes manifests
│   ├── secrets.yaml         # (Git ignored)
│   ├── secrets.yaml.example
│   ├── postgres.yaml
│   ├── spring.yaml
│   ├── next.yaml
│   ├── ingress.yaml
│   ├── elk/
│   │   ├── elasticsearch.yaml
│   │   ├── kibana.yaml
│   │   └── filebeat.yaml
│   └── monitoring/
│       ├── prometheus.yaml
│       └── grafana.yaml
├── helm/k8s-practice/       # Helm chart
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-secret.yaml.example
│   └── templates/
├── deploy.sh
├── cleanup.sh
└── setup-ingress.sh
```

## 배포 방법

### 방법 1: Raw Kubernetes Manifests

```bash
# 1. Docker 이미지 빌드
docker build -t spring-app:latest ./spring-app
docker build -t next-app:latest ./next-app

# 2. Secrets 설정
cp k8s/secrets.yaml.example k8s/secrets.yaml
# secrets.yaml 편집하여 실제 값 설정

# 3. 리소스 배포
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/spring.yaml
kubectl apply -f k8s/next.yaml
kubectl apply -f k8s/elk/
kubectl apply -f k8s/monitoring/
kubectl apply -f k8s/ingress.yaml
```

### 방법 2: Helm Chart

```bash
# 1. Docker 이미지 빌드
docker build -t spring-app:latest ./spring-app
docker build -t next-app:latest ./next-app

# 2. Secrets 설정
cp helm/k8s-practice/values-secret.yaml.example helm/k8s-practice/values-secret.yaml
# values-secret.yaml 편집

# 3. Helm 배포
helm install k8s-practice ./helm/k8s-practice -f ./helm/k8s-practice/values-secret.yaml
```

### 자동 배포 스크립트

```bash
# 전체 배포
./deploy.sh

# 정리
./cleanup.sh
```

## 접속 URL

| 서비스 | URL |
|--------|-----|
| Next.js (Frontend) | http://localhost/ |
| Spring Boot (API) | http://localhost/api/ |
| Kibana | http://kibana.localhost/ |
| Prometheus | http://prometheus.localhost/ |
| Grafana | http://grafana.localhost/ |

> **Note**: `*.localhost`는 대부분의 브라우저에서 자동으로 `127.0.0.1`로 연결됩니다.

## API 엔드포인트

### Spring Boot API

```bash
# Health Check
GET /actuator/health

# Prometheus Metrics
GET /actuator/prometheus

# Messages CRUD
GET    /api/messages          # 전체 조회
POST   /api/messages          # 생성 (body: { "content": "..." })
DELETE /api/messages/{id}     # 삭제
```

## 주요 기능

### 로깅 (ELK Stack)
- Filebeat가 DaemonSet으로 각 노드의 컨테이너 로그 수집
- Elasticsearch에 저장
- Kibana에서 시각화 및 검색

### 모니터링 (Prometheus + Grafana)
- Prometheus가 Spring Boot `/actuator/prometheus` 엔드포인트 스크래핑
- Kubernetes Pod 자동 발견 (kubernetes_sd_configs)
- Grafana 대시보드에서 메트릭 시각화

### Secret 관리
- secrets.yaml은 .gitignore에 포함
- secrets.yaml.example을 템플릿으로 제공
- Helm 사용 시 values-secret.yaml로 분리

## 트러블슈팅

### Pod 상태 확인
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### 서비스 연결 확인
```bash
kubectl get svc
kubectl get ingress
```

### PostgreSQL 접속
```bash
kubectl exec -it <postgres-pod> -- psql -U myuser -d myapp
```

### Elasticsearch 상태 확인
```bash
kubectl exec -it <es-pod> -- curl localhost:9200/_cluster/health?pretty
```

## 리소스 정리

```bash
# Helm 사용 시
helm uninstall k8s-practice

# Raw manifests 사용 시
kubectl delete -f k8s/ingress.yaml
kubectl delete -f k8s/monitoring/
kubectl delete -f k8s/elk/
kubectl delete -f k8s/next.yaml
kubectl delete -f k8s/spring.yaml
kubectl delete -f k8s/postgres.yaml
kubectl delete -f k8s/secrets.yaml

# 또는 cleanup.sh 실행
./cleanup.sh
```
