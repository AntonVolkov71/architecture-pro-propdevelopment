### Запуск миникуба
car
- с политикой аудита (логи запросы/ответы)
```the windows the dlinno, запуск из ./Task6

mkdir -p ~/.minikube/files/etc/ssl/certs

cat <<EOF > ~/.minikube/files/etc/ssl/certs/audit-policy.yaml
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  verbs: ["create", "delete", "update", "patch", "get", "list"]
  resources:
    - group: ""
      resources: ["pods", "secrets", "configmaps", "serviceaccounts", "roles", "rolebindings"]
- level: Metadata
  resources:
    - group: ""
      resources: ["*"]
EOF

minikube start `
  --cni=calico `
  --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml `
  --extra-config=apiserver.audit-log-path=- `
  --extra-config=apiserver.audit-log-format=json


# если шо ..
minikube stop   
minikube delete
minikube delete --purge --all
```

- чекаем запуск миникуба
```
minikube status // все должны быть running

minikube ssh
ls /var/logs // здеся должен быть лог
```

- зажигаем фейрверк симуляций действий
```
bash ./kuber/simulate-incident.sh
```

- достаем логи наружу в файл audit.log
```
kubectl -n kube-system logs kube-apiserver-minikube > audit.log
```

- фильтруем логи скриптом, создавая файл артефакт
  - jq бы установить
```
bash filter-audit.sh
```
  - создатсья два файла
    - один с логами отфильтрованными, но оъекты внутри JSON просто без запятых тупо друг за другом
      - [audit-extract.json](audit-extract.json)
    - второй с корректным JSON массивом логов
      - [audit-extract-array.json](audit-extract-array.json)

## Анализ выборки из логов
- [analysis.md](analysis.md)