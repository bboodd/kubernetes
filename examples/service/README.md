# Service 예제

Service는 동적으로 변하는 Pod를 **안정적으로 네트워크에 노출**시키는 리소스입니다.

---

## 왜 Service가 필요한가?

- Pod는 재생성될 때마다 **IP가 바뀜**
- 클라이언트가 매번 바뀌는 IP를 추적하기 어려움
- Service는 **고정된 진입점**을 제공

```
Client → Service (고정) → Pod (동적 IP)
                       → Pod (동적 IP)
                       → Pod (동적 IP)
```

---

## 파일 설명

- `deployment.yaml` - Pod를 생성할 Deployment
- `service-clusterip.yaml` - ClusterIP 타입 (내부 전용)
- `service-nodeport.yaml` - NodePort 타입 (외부 접근 가능)

---

## 실습

### 1. Deployment 먼저 생성

```bash
kubectl apply -f deployment.yaml
kubectl get pods
```

---

### 2. ClusterIP Service (내부 전용)

```bash
kubectl apply -f service-clusterip.yaml
kubectl get services
```

클러스터 **내부**에서만 접근 가능:
```bash
# 테스트용 Pod에서 접근
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl -s my-service:80

```

---

### 3. NodePort Service (외부 접근)

```bash
kubectl apply -f service-nodeport.yaml
kubectl get services
```

예상 출력:
```
NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
my-service-np     NodePort   10.96.xxx.xxx   <none>        80:30080/TCP   10s
```

**브라우저에서 접속**:
```
http://localhost:30080
```

---

### 4. Service가 Pod를 찾는 원리

```bash
# Service의 selector 확인
kubectl describe service my-service-np

# 연결된 Pod의 IP 확인 (Endpoints)
kubectl get endpoints my-service-np
```

> Service는 **label selector**로 Pod를 찾습니다.

---

### 5. 로드밸런싱 테스트

```bash
# 여러 번 요청해보기
for i in {1..5}; do curl -s localhost:30080 | grep "Server"; done
```

요청이 여러 Pod에 분산되는 것을 확인할 수 있습니다.

---

## Service 타입 비교

| 타입 | 용도 | 접근 방법 |
|------|------|-----------|
| ClusterIP | 내부 통신 | 클러스터 내부에서만 |
| NodePort | 개발/테스트 | `노드IP:포트` |
| LoadBalancer | 프로덕션 | 클라우드 LB 연동 |

---

## 정리

```bash
kubectl delete -f service-nodeport.yaml
kubectl delete -f service-clusterip.yaml
kubectl delete -f deployment.yaml
```

---

## 핵심 포인트

1. Service는 Pod의 **고정 진입점**
2. Label selector로 **대상 Pod 선택**
3. 자동 **로드밸런싱**
4. NodePort로 **외부 노출** 가능

---

## 전체 아키텍처

```
외부 요청
    ↓
Service (NodePort:30080)
    ↓ (로드밸런싱)
┌───────┬───────┬───────┐
│ Pod 1 │ Pod 2 │ Pod 3 │
└───────┴───────┴───────┘
    ↑
Deployment (replica: 3)
```
