# Pod 예제

Pod는 Kubernetes에서 배포 가능한 **가장 작은 단위**입니다.

---

## 파일 설명

- `pod.yaml` - 기본 Pod 정의 파일

---

## 실습

### 1. Pod 생성

```bash
kubectl apply -f pod.yaml
```

### 2. Pod 상태 확인

```bash
# Pod 목록 확인
kubectl get pods

# 상세 정보 확인
kubectl describe pod my-pod
```

예상 출력:
```
NAME     READY   STATUS    RESTARTS   AGE
my-pod   1/1     Running   0          30s
```

### 3. Pod 로그 확인

```bash
kubectl logs my-pod

# 실시간 로그
kubectl logs -f my-pod
```

### 4. Pod 내부 접속

```bash
kubectl exec -it my-pod -- /bin/sh

# 내부에서 테스트
wget -qO- localhost
exit
```

### 5. Port Forward (외부에서 접근)

Service 없이 로컬에서 Pod에 직접 접근하는 방법입니다.

```bash
# 로컬 8080 → Pod 80 포트 연결
kubectl port-forward my-pod 8080:80
```

브라우저에서 접속:
```
http://localhost:8080
```

> 💡 port-forward는 **디버깅/테스트 용도**입니다. 프로덕션에서는 Service를 사용하세요.

종료: `Ctrl + C`

### 6. Pod 삭제 및 재생성 테스트

```bash
# Pod 삭제
kubectl delete pod my-pod

# 다시 확인 - Pod가 자동으로 재생성되지 않음!
kubectl get pods
```

> ⚠️ **중요**: Pod는 삭제되면 자동으로 재생성되지 않습니다.
> 이것이 Deployment를 사용하는 이유입니다.

---

## 정리

```bash
kubectl delete -f pod.yaml
```

---

## 핵심 포인트

1. Pod는 **임시 리소스** - 죽으면 끝
2. 자동 복구 기능 **없음**
3. 실무에서는 **Deployment**를 통해 관리

---

## 다음 단계

[Deployment 예제](../deployment/README.md)로 이동하여 자동 복구와 롤링 업데이트를 배워보세요.
