# Kubernetes 스터디

Docker Compose가 컨테이너를 **실행**하는 도구라면, 

Kubernetes는 컨테이너의 **실행 + 자동 관리**(오토스케일링, 롤링업데이트, 롤백, 장애복구)를 담당하는 도구입니다.

---

## 학습 순서

### 1. 개념 이해
📖 [docs/01-concepts.md](./docs/01-concepts.md)
- Pod, ReplicaSet, Deployment, Service 개념
- 리소스 계층 구조
- 네트워크 개념

### 2. 환경 설정
🔧 [docs/02-setup.md](./docs/02-setup.md)
- Docker Desktop에서 Kubernetes 활성화
- kubectl 설치 확인
- 기본 명령어 테스트

### 3. 실습 예제
🚀 [docs/03-examples.md](./docs/03-examples.md)
- 예제별 실습 가이드
- 자주 쓰는 명령어 모음

---

## 예제 목록

| 예제 | 설명 | 실습 |
|------|------|------|
| [Pod](./examples/pod) | 가장 작은 배포 단위 | Pod 생성, 삭제, 로그 확인 |
| [Deployment](./examples/deployment) | 자동 복구 + 롤링 업데이트 | 스케일링, 업데이트, 롤백 |
| [Service](./examples/service) | Pod 네트워크 노출 | ClusterIP, NodePort |

---

## 핵심 개념 요약

### 리소스 계층
```
Deployment  →  배포 관리 (롤링업데이트, 롤백)
    └── ReplicaSet  →  Pod 개수 유지 (자동 복구)
            └── Pod  →  컨테이너 실행
```

### 주요 특징

| 리소스 | 역할 | 자동복구 | 롤링업데이트 | 롤백 |
|--------|------|:--------:|:------------:|:----:|
| Pod | 컨테이너 실행 | ❌ | ❌ | ❌ |
| ReplicaSet | Pod 개수 유지 | ✅ | ❌ | ❌ |
| Deployment | 배포 관리 | ✅ | ✅ | ✅ |
| Service | 네트워크 노출 | - | - | - |

---

## 빠른 시작

```bash
# 1. Kubernetes 활성화 확인
kubectl get nodes

# 2. 첫 번째 예제 실행
cd examples/pod
kubectl apply -f pod.yaml
kubectl get pods

# 3. 정리
kubectl delete -f pod.yaml
```

---

## 자주 쓰는 명령어

```bash
# 조회
kubectl get pods|deployments|services|all

# 상세 정보
kubectl describe pod <name>
kubectl logs <pod-name>

# 생성/삭제
kubectl apply -f <file>.yaml
kubectl delete -f <file>.yaml

# 디버깅
kubectl exec -it <pod-name> -- /bin/sh
```

---

## 프로젝트 구조

```
kubernetes/
├── README.md              # 이 파일
├── docs/
│   ├── 01-concepts.md     # 핵심 개념
│   ├── 02-setup.md        # 환경 설정
│   └── 03-examples.md     # 실습 가이드
└── examples/
    ├── pod/               # Pod 예제
    ├── deployment/        # Deployment 예제
    └── service/           # Service 예제
```

---

## 환경

- Docker Desktop (Kubernetes 내장)
- macOS / Windows / Linux
