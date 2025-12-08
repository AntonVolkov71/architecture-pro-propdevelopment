#!/bin/bash
set -euo pipefail

NS="audit-zone"

echo "=== Проверка securityContext у pod'ов в namespace ${NS} ==="

kubectl get pods -n "$NS" -o json | jq -r '
  .items[]
  | .metadata.name as $pod
  | .spec.containers[]
  | {
      pod: $pod,
      container: .name,
      privileged: .securityContext.privileged,
      runAsNonRoot: .securityContext.runAsNonRoot,
      readOnlyRootFilesystem: .securityContext.readOnlyRootFilesystem,
      allowPrivilegeEscalation: .securityContext.allowPrivilegeEscalation,
      capabilitiesDrop: .securityContext.capabilities.drop
    }
'
