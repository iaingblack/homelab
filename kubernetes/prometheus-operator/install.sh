# https://rpi4cluster.com/monitoring/k3s-prometheus-oper/
# https://prometheus-operator.dev/docs/user-guides/getting-started/
#LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
#curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml > bundle.yaml

kubectl create namespace monitoring
wget https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
sed -i 's/namespace: default/namespace: monitoring/g' bundle.yaml
kubectl apply -f bundle.yaml