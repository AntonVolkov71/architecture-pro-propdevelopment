#!/bin/bash
set -euo pipefail

NS="audit-zone"

echo "=== Проверка: namespace и PodSecurity ==="
kubectl get ns "$NS" --show-labels

echo
echo "=== Шаг 1: Пытаемся применить insecure-манифесты  ==="
if kubectl apply -n "$NS" -f ../insecure-manifests/; then
  echo "ОШИБКА: insecure-манифесты применились, а должны были быть отклонены"
  exit 1
else
  echo "ОК: insecure-манифесты отклонены admission / PodSecurity / Gatekeeper"
fi

echo
echo "=== Шаг 2: Применяем secure-манифесты  ==="
kubectl apply -n "$NS" -f ../secure-manifests/

echo
echo "=== Текущее состояние pod'ов в ${NS} ==="
kubectl get pods -n "$NS" -o wide
