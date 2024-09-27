# Deploying Golang application on Kubernetes without Dockerfile

## Building the Go application using BuildSafe
BuildSafe is a tool to simplify the dev to prod application build securely using nix under the hood.

### Installing Buildsafe:
#### Install nix
```
curl -L https://nixos.org/nix/install | sh
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
```
#### Create and edit bsf.conf file file
```
sudo mkdir /etc/nix
sudo vim /etc/nix/nix.conf
```
- Add this in nix.conf:
```
experimental-features = nix-command flakes
```
#### Now install Buildsafe
```
nix profile install "github:buildsafedev/bsf"
```
### Building the Artifact using Buildsafe:

- Initialize it
```
bsf init
```
Above command will automatically detect that its a Go program and setup common development and runtime dependencies for it.
- We can look at what it generated-
```
ls bsf.hcl
```
Output-
```
packages {
  development = ["go@1.21.6", "gotools@0.16.1", "delve@1.22.0"]
  runtime     = ["cacert@3.95"]
}

gomodule {
  name    = "devops-go-project.git"
  src     = "./."
  ldFlags = null
  tags    = null
  doCheck = false
}
```
- Now we want to build OCI artifacts for our app.
```
vi bsf.hcl
```
Paste this block-
```
oci "dev" {
  name         = "ttl.sh/buildsafe/goapp:dev"
  layers       = ["packages.runtime + packages.dev"]
  cmd          = ["/bin/go-server-example"]
}
```
- Let’s try to build Go application now.
```
bsf build
```
Output-
```
Build completed successfully, please check the bsf-result directory
```
- We can execute the binary from
```
bsf-result/result/bin/devops-go-project.git
```
The application will start running on `localhost:8080`
- Load the artifact in docker
```
bsf oci dev --platform linux/amd64 --load-docker
```
NOTE: the first build usually takes a while as none of the dependencies are likely present to build OCI images.
- Push the image in the `ttl.sh` repo
```
docker push ttl.sh/buildsafe/goapp:dev
```
And that’s it! You have successfully built and pushed your Go application without a Dockerfile. Want to know the coolest part? This OCI artifact is CVE-free, meaning it is a 0-CVE artifact, free of any vulnerabilities.

## Deploying it to Kubernetes
### Installing nginx ingress controller
- Create nginx namespace
```
kubectl create ns ingress-nginx
```
- Install nginx with Helm package manager
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```
- Update your Helm repositories.
```
helm repo update
```
- Install the NGINX Ingress Controller.
```
helm upgrade ing --install ingress-nginx/ingress-nginx \
    --namespace ingress-nginx \
    --set controller.image.repository="registry.k8s.io/ingress-nginx/controller" \
    --set controller.image.tag="v1.10.1" \
    --set-string controller.config.proxy-body-size="50m" \
    --set controller.service.externalTrafficPolicy="Local"
```
- Access your NodeBalancer’s assigned external IP address.
```
kubectl --namespace ingress-nginx get services -o wide -w ing-ingress-nginx-controller
```
- Copy the IP address of the `EXTERNAL IP`
- Use your DNS control panel to create this wildcard A record and assign this IP value to that A Record in your domain.

### Installing Cert Manager
- Install the cert-manager
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml
```
- Create a cluster issuer to represent a certificate authority (CA) capable of generating signed certificates by honoring certificate signing requests.
```
wget https://gist.githubusercontent.com/lvnilesh/b07132d67fdda57f542ea1651fd4e925/raw/9f3ecfede780c17ffd84b5467ea3b86335a9b9c1/cluster-issuer.yaml
```
- Edit the issuer with your own credentials.
```
vi cluster-issuer.yaml
```
- Apply this command after editing the file.
```
kubectl apply -f cluster-issuer.yaml
```
- Create a secret that contains your CloudFlare API Key
```
API_KEY=$(echo -n "YOUR_API_KEY" | base64)
```
```
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-key
  namespace: cert-manager
type: Opaque
data:
  api-key: $API_KEY
EOF
```
Now, we can run services in your cluster and deliver to our users automatically via ingress in a secure fashion thanks to cert manager and letsencrypt.

### Create Deployment and Service and Ingress
- Deployment
```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-web-server
  labels:
    app: go-web-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: go-web-server
  template:
    metadata:
      labels:
        app: go-web-server
    spec:
      containers:
      - name: go-web-server
        image: ttl.sh/gonew/go:demo
        ports:
        - containerPort: 8080
EOF
```
- Service
```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: go-web-server
spec:
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: go-web-server
EOF
```
- Ingress
```
cat << EOF | kubectl apply -f -
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: go-web-server
  annotations:
    # kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  rules:
    - host: go-web-server.devfun.me
      http:
        paths:
          - backend:
              service:
                name: go-web-server
                port:
                  number: 80
            path: /
            pathType: Prefix
  tls:
    - hosts:
        - "go-web-server.devfun.me"
      secretName: go-web-server
EOF
```
Edit this ingress manifest with your domain detail that would map that DNS name to the service you created earlier.
The site is deployed successfully in k8s using TLS protection!

![go-web-server](https://github.com/user-attachments/assets/5270b7d3-9963-4c8e-b5d6-de91f8237a73)




