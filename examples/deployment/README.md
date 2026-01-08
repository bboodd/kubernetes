# Deployment 예제

Deployment는 Pod의 **자동 복구, 롤링 업데이트, 롤백**을 관리하는 상위 리소스입니다.

---

## 파일 설명

- `deployment.yaml` - Deployment 정의 파일

---

## 실습

### 1. Deployment 생성

```bash
kubectl apply -f deployment.yaml
```

### 2. 상태 확인

```bash
# Deployment 확인
kubectl get deployments

# Pod 확인 (자동 생성된 Pod들)
kubectl get pods

# ReplicaSet 확인 (Deployment가 자동 생성)
kubectl get replicasets
```

예상 출력:
```
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment   3/3     3            3           30s
```

---

### 3. 자동 복구 테스트

```bash
# 현재 Pod 목록 확인
kubectl get pods

# Pod 하나 삭제
kubectl delete pod <pod-name>

# 다시 확인 - 새 Pod가 자동 생성됨!
kubectl get pods
```

> ✅ Deployment는 항상 지정된 replica 수를 유지합니다.

---

### 4. 스케일링

```bash
# replica 수를 5개로 변경
kubectl scale deployment my-deployment --replicas=5

# 확인
kubectl get pods

# 다시 3개로 줄이기
kubectl scale deployment my-deployment --replicas=3
```

---

### 5. Port Forward (외부에서 접근)

Service 없이 특정 Pod에 직접 접근하는 방법입니다.

```bash
# Pod 이름 확인
kubectl get pods

# 로컬 8080 → Pod 80 포트 연결
kubectl port-forward deployment/my-deployment 8080:80
```

브라우저에서 접속:
```
http://localhost:8080
```

> 💡 `deployment/이름`으로 지정하면 자동으로 하나의 Pod를 선택합니다.

종료: `Ctrl + C`

---

### 6. 롤링 업데이트

```bash
# 이미지 버전 변경 (nginx:latest → nginx:1.24)
kubectl set image deployment/my-deployment nginx-container=nginx:1.24

# 업데이트 상태 확인
kubectl rollout status deployment/my-deployment

# Pod 확인 - 새 버전으로 교체됨
kubectl get pods
```

---

### 7. 롤백

```bash
# 배포 히스토리 확인
kubectl rollout history deployment/my-deployment

# 이전 버전으로 롤백
kubectl rollout undo deployment/my-deployment

# 확인
kubectl rollout status deployment/my-deployment
```

---

## 정리

```bash
kubectl delete -f deployment.yaml
```

---

## Pod vs Deployment 비교

| 기능 | Pod | Deployment |
|------|:---:|:----------:|
| 컨테이너 실행 | ✅ | ✅ |
| 자동 복구 | ❌ | ✅ |
| 롤링 업데이트 | ❌ | ✅ |
| 롤백 | ❌ | ✅ |
| 스케일링 | ❌ | ✅ |

---

## 핵심 포인트

1. Deployment는 **ReplicaSet을 자동 관리**
2. Pod 장애 시 **자동 복구**
3. 무중단 배포를 위한 **롤링 업데이트**
4. 문제 발생 시 **롤백** 가능

---

## 다음 단계

[Service 예제](../service/README.md)로 이동하여 Pod를 외부에 노출하는 방법을 배워보세요.
