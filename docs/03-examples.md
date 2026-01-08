# 예제 실습 가이드

이 문서에서는 Kubernetes의 핵심 리소스들을 직접 생성하고 관리해봅니다.

---

## 예제 목록

| 예제 | 설명 | 폴더 |
|------|------|------|
| Pod | 가장 기본적인 컨테이너 실행 | [examples/pod](../examples/pod) |
| Deployment | 롤링 업데이트와 자동 복구 | [examples/deployment](../examples/deployment) |
| Service | Pod를 외부에 노출 | [examples/service](../examples/service) |

---

## 실습 순서

### 1단계: Pod 이해하기
```bash
cd examples/pod
# README.md 따라 실습
```
- Pod 생성/삭제
- Pod 로그 확인
- Pod 내부 접속

### 2단계: Deployment 이해하기
```bash
cd examples/deployment
# README.md 따라 실습
```
- Deployment 생성
- 스케일링 (replica 수 변경)
- 롤링 업데이트
- 롤백

### 3단계: Service 이해하기
```bash
cd examples/service
# README.md 따라 실습
```
- Service로 Pod 노출
- 외부에서 접근
- Service 타입 비교

---

## 자주 쓰는 kubectl 명령어

### 리소스 조회
```bash
kubectl get pods                    # Pod 목록
kubectl get deployments             # Deployment 목록
kubectl get services                # Service 목록
kubectl get all                     # 모든 리소스
```

### 상세 정보
```bash
kubectl describe pod <pod-name>     # Pod 상세 정보
kubectl logs <pod-name>             # Pod 로그
kubectl logs -f <pod-name>          # 로그 실시간 확인
```

### 리소스 생성/삭제
```bash
kubectl apply -f <파일>.yaml        # 리소스 생성/업데이트
kubectl delete -f <파일>.yaml       # 리소스 삭제
```

### 디버깅
```bash
kubectl exec -it <pod-name> -- /bin/sh   # Pod 내부 접속
kubectl port-forward <pod-name> 8080:80  # 포트 포워딩
```

---

## 실습 팁

1. **YAML 파일 수정 후** 항상 `kubectl apply -f` 로 적용
2. **리소스 삭제 시** `kubectl delete -f` 사용
3. **문제 발생 시** `kubectl describe`와 `kubectl logs`로 디버깅
4. **실습 완료 후** 리소스 정리를 잊지 마세요

---

## 다음 단계

각 예제 폴더의 README.md를 따라 순서대로 실습하세요:

1. [Pod 예제](../examples/pod/README.md)
2. [Deployment 예제](../examples/deployment/README.md)
3. [Service 예제](../examples/service/README.md)
