# 환경 설정 (Docker Desktop)

## 사전 요구사항

- Docker Desktop 설치
- 최소 4GB RAM 할당 권장

---

## 1. Docker Desktop에서 Kubernetes 활성화

### macOS / Windows

1. Docker Desktop 실행
2. 설정(Settings) → **Kubernetes** 탭
3. **Enable Kubernetes** 체크
4. **Apply & Restart** 클릭
5. 하단에 **Kubernetes running** 표시 확인 (1-2분 소요)

---

## 2. kubectl 설치 확인

Docker Desktop을 통해 Kubernetes를 활성화하면 `kubectl`이 자동으로 설치됩니다.

```bash
# 버전 확인
kubectl version --client

# 클러스터 연결 확인
kubectl cluster-info
```

### 정상 출력 예시
```
Kubernetes control plane is running at https://127.0.0.1:6443
```

---

## 3. 기본 명령어 테스트

```bash
# 노드 목록 확인
kubectl get nodes

# 모든 리소스 확인
kubectl get all

# 네임스페이스 확인
kubectl get namespaces
```

### 예상 출력
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   1d    v1.28.2
```

---

## 4. 컨텍스트 확인

여러 Kubernetes 클러스터를 사용할 경우 컨텍스트 확인이 필요합니다.

```bash
# 현재 컨텍스트 확인
kubectl config current-context

# 사용 가능한 컨텍스트 목록
kubectl config get-contexts

# 컨텍스트 변경 (필요시)
kubectl config use-context docker-desktop
```

---

## 5. 대시보드 설치 (선택사항)

웹 UI로 클러스터를 관리하고 싶다면:

```bash
# 대시보드 설치
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# 프록시 실행
kubectl proxy

# 브라우저에서 접속
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

---

## 트러블슈팅

### Kubernetes가 시작되지 않을 때

```bash
# Docker Desktop 재시작
# 또는 Kubernetes 리셋: Settings → Kubernetes → Reset Kubernetes Cluster
```

### kubectl 명령이 안 될 때

```bash
# 컨텍스트 확인 및 설정
kubectl config use-context docker-desktop
```

### 리소스 부족 에러

Docker Desktop 설정에서 메모리를 4GB 이상으로 늘려주세요.

---

## 다음 단계

환경 설정이 완료되었다면 [03-examples.md](./03-examples.md)에서 실습 예제를 진행하세요.
