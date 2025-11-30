### Запуск миникуба

- с политикой аудита (логи запросы/ответы)
```the windows the dlinno, запуск из ./Task6

minikube start `
  --mount --mount-string="${PWD}:/var/lib/minikube/audit" `
  --extra-config=apiserver.audit-policy-file=/var/lib/minikube/audit/audit-policy.yaml `
  --extra-config=apiserver.audit-log-path=/var/log/audit.log 

minikube update-context


# если шо ..
minikube stop   
minikube delete
```
- чекаем запуск миникуба 
```
minikube status // все должны быть running

minikube ssh
ls /var/logs // здеся должен быть лог
ls /var/lib/minikube/audit/ // здесь файлы с нашего двора
```

- зажигаем фейрверк симуляций действий
```
bash ./kuber/simulate-incident.sh
```

- достаем логи наружу
```

```