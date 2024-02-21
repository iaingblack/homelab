LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml > bundle.yaml
sed -i 's/namespace: default/namespace: monitoring/g' bundle.yaml
cat bundle.yaml |  grep 'namespace: ' bundle.yaml