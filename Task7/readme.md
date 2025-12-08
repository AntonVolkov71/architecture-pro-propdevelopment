## Создадим namespace audit-zone 
- самый запрещающий уровень
- [01-create-namespace.yaml](01-create-namespace.yaml)

## Три манифеста с нарушениями
- insecure-manifests/*.yaml
- создаем namespace и пытаемся добавить поды
```
kubectl apply -f .\01-create-namespace.yaml
 
kubectl apply -f insecure-manifests/       
    Error from server (Forbidden): error when creating "insecure-manifests\\01-privileged-pod.yaml": pods "pod-privileged" is forbidden: violates PodSecurity "restricted:latest": privileged (container "nginx" must not set securityContext.privileged=true), allowPrivilegeEscalation !
    = false (container "nginx" must set securityContext.allowPrivilegeEscalation=false), unrestricted capabilities (container "nginx" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "nginx" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "nginx" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    Error from server (Forbidden): error when creating "insecure-manifests\\02-hostpath-pod.yaml": pods "hostpath-pod" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "c" must set securityContext.allowPrivilegeEscalation=false), 
    unrestricted capabilities (container "c" must set securityContext.capabilities.drop=["ALL"]), restricted volume types (volume "hostdata" uses restricted volume type "hostPath"), runAsNonRoot != true (pod or container "c" must set securityContext.runAsNonRoot=true), seccompProfile (pod or container "c" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    Error from server (Forbidden): error when creating "insecure-manifests\\03-root-user-pod.yaml": pods "root-user-pod" is forbidden: violates PodSecurity "restricted:latest": allowPrivilegeEscalation != false (container "c" must set securityContext.allowPrivilegeEscalation=false)
    , unrestricted capabilities (container "c" must set securityContext.capabilities.drop=["ALL"]), runAsNonRoot != true (pod or container "c" must set securityContext.runAsNonRoot=true), runAsUser=0 (container "c" must not set runAsUser=0), seccompProfile (pod or container "c" must set securityContext.seccompProfile.type to "RuntimeDefault" or "Localhost")
    PS E:\Edication\cource_architector\5\Task7> kubectl get pods -n audit-zone
    No resources found in audit-zone namespace.
```
- namespace создался, поды нет

## Переписываем манифесты на секурные
- secure-manifests/*.yaml
- запускаем 
```
kubectl apply -f secure-manifests/

// стартанули
pod/secure-pod-privileged created
pod/secure-hostpath-pod created
pod/secure-root-fixed created


kubectl get pods -n audit-zone

NAME                    READY   STATUS                       RESTARTS   AGE
secure-hostpath-pod     0/1     CreateContainerConfigError   0          21m
secure-pod-privileged   0/1     CreateContainerConfigError   0          21m
secure-root-fixed       0/1     CreateContainerConfigError   0          20m

```

## OPA Gatekeeper политика 
- Запрет с securityContext.privileged=true
    - [privileged.yaml](gatekeeper/constraint-templates/privileged.yaml)
- Запрет hostPath в .spec.volumes
  - [hostpath.yaml](gatekeeper/constraint-templates/hostpath.yaml)
- требуем runAsNonRoot=true
  - [runasnonroot.yaml](gatekeeper/constraint-templates/runasnonroot.yaml)

- привязка Gatekeeper к audit-zone
  - privileged constraint
    - [privileged.yaml](gatekeeper/constraints/privileged.yaml)
  - hostPath constraint
    - [hostpath.yaml](gatekeeper/constraints/hostpath.yaml)
  - runAsNonRoot
    - [runasnonroot.yaml](gatekeeper/constraints/runasnonroot.yaml)
- Применить Gatekeeper templates + constraints
```
// при устновленном gatekeeper
kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/
```
  
## Политика аудита
- на наш namespace заропсы/ответы CRUD и метаданные
  - [audit-policy.yaml](audit-policy.yaml)

### Сркипт проверка admission и гейткипера
- [verify-admission.sh](verify/verify-admission.sh)
- запуск
```
bash ./verify/verify-admission.sh
```

### Скрипт проверка секурных контекстов у подов
- [validate-security.sh](verify/validate-security.sh)
- запуск
```
bash ./verify/validate-security.sh
```
