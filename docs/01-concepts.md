# Kubernetes 핵심 개념

## Kubernetes란?

Docker Compose가 여러 컨테이너를 **실행**하는 도구라면, Kubernetes는 컨테이너의 **실행 + 자동 관리**를 담당하는 상위 도구입니다.

```
Docker Compose: 컨테이너 실행
Kubernetes: 컨테이너 실행 + 오토스케일링 + 롤링업데이트 + 롤백 + 장애복구
```

## 핵심 리소스 계층 구조

```
Deployment (최상위 - 배포 관리)
    └── ReplicaSet (중간 - Pod 개수 유지)
            └── Pod (최하위 - 컨테이너 실행)
                    └── Container
```

---

## Pod

> 쿠버네티스에서 배포 가능한 **가장 작은 단위**

### 특징
- 컨테이너를 실행하는 실행환경
- 보통 **하나의 Pod = 하나의 컨테이너** (설계 원칙)
- 여러 컨테이너 실행도 가능 (사이드카 패턴)

### 같은 Pod 내 컨테이너 간 통신
- `localhost`로 통신 가능
- 저장공간(Volume) 공유 가능

### 한계
- **임시 리소스**: 짧은 수명을 가짐
- **자가 관리 불가**: 스스로 복구하는 기능 없음
- 일반적으로 상위 컨트롤러(Deployment)로 관리

---

## ReplicaSet

> Pod를 **원하는 개수만큼 유지**하는 컨트롤러

### 기능
- ✅ 동일한 Pod를 지정된 개수만큼 유지
- ✅ Pod가 죽으면 자동으로 새 Pod 생성 (자동 복구)
- ✅ 고가용성 보장

### 한계
- ❌ 롤링 업데이트 불가
- ❌ 롤백 불가

### 실무에서는?
- ReplicaSet을 직접 사용하는 경우는 드묾
- 대부분 **Deployment**를 통해 간접적으로 사용

---

## Deployment

> ReplicaSet을 관리하는 **최상위 리소스**

### 기능
- ✅ ReplicaSet 관리
- ✅ 자동 복구 (Pod 장애 시)
- ✅ **롤링 업데이트**: 무중단 배포
- ✅ **롤백**: 이전 버전으로 되돌리기
- ✅ 스케일링: replica 수 조절

### 왜 Deployment를 사용하는가?
```
Pod만 사용        → 장애 시 수동 복구 필요
ReplicaSet 사용   → 자동 복구 O, 업데이트/롤백 X
Deployment 사용   → 자동 복구 O, 업데이트/롤백 O ✅
```

---

## Service

> 동적으로 변하는 Pod를 **안정적으로 네트워크에 노출**시키는 리소스

### 왜 필요한가?
- Pod는 삭제/재생성될 때마다 **새로운 IP 주소**를 할당받음
- 클라이언트가 매번 바뀌는 IP를 추적하기 어려움
- Service는 **고정된 진입점**을 제공

### Service 타입
| 타입 | 설명 |
|------|------|
| ClusterIP | 클러스터 내부에서만 접근 가능 (기본값) |
| NodePort | 외부에서 노드IP:포트로 접근 가능 |
| LoadBalancer | 클라우드 로드밸런서 연동 |

### 동작 원리
```
Client → Service (고정 IP) → Pod (동적 IP)
                           → Pod (동적 IP)
                           → Pod (동적 IP)
```

---

## 네트워크 개념

### Pod 간 통신
- 같은 클러스터 내 모든 Pod는 서로 통신 가능
- 같은 Pod 내 컨테이너는 `localhost`로 통신

### Service를 통한 접근
```yaml
# 다른 Pod에서 Service 접근
http://서비스이름:포트
http://my-service:80
```

---

## 요약 비교표

| 리소스 | 역할 | 자동복구 | 롤링업데이트 | 롤백 |
|--------|------|:--------:|:------------:|:----:|
| Pod | 컨테이너 실행 | ❌ | ❌ | ❌ |
| ReplicaSet | Pod 개수 유지 | ✅ | ❌ | ❌ |
| Deployment | 배포 관리 | ✅ | ✅ | ✅ |
| Service | 네트워크 노출 | - | - | - |

---

## 다음 학습 단계

이 문서에서 다룬 기본 개념(Pod, Deployment, Service)을 익혔다면, 다음 개념들을 학습하세요.

### Step 1: 리소스 연결과 격리

| 개념 | 설명 |
|------|------|
| **Label & Selector** | 리소스 간 연결 방식. Service가 Pod를 찾는 원리 |
| **Namespace** | 리소스 격리. dev/staging/prod 환경 분리 |

### Step 2: 설정 관리

| 개념 | 설명 |
|------|------|
| **ConfigMap** | 환경변수, 설정 파일 관리 |
| **Secret** | 비밀번호, API 키 등 민감정보 관리 |

### Step 3: 네트워크 심화

| 개념 | 설명 |
|------|------|
| **Ingress** | 도메인 기반 HTTP 라우팅 (my-app.com → Service) |
| **NetworkPolicy** | Pod 간 네트워크 접근 제어 |

### Step 4: 데이터 저장

| 개념 | 설명 |
|------|------|
| **Volume** | 컨테이너 데이터 저장 |
| **PersistentVolume (PV)** | 클러스터 레벨 스토리지 |
| **PersistentVolumeClaim (PVC)** | Pod에서 스토리지 요청 |

### Step 5: 다양한 워크로드

| 개념 | 설명 |
|------|------|
| **StatefulSet** | DB처럼 상태가 있는 앱 (고정 이름, 순서 보장) |
| **DaemonSet** | 모든 노드에 Pod 1개씩 배포 (로그 수집, 모니터링) |
| **Job / CronJob** | 일회성 작업 / 주기적 작업 (배치, 백업) |

### Step 6: 운영

| 개념 | 설명 |
|------|------|
| **HPA** | Horizontal Pod Autoscaler - CPU/메모리 기반 자동 스케일링 |
| **Resource Limits** | Pod CPU/메모리 제한 설정 |
| **Probe** | 헬스체크 (liveness, readiness) |
