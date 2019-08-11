# vault-kubernetes-authenticator

The `vault-kubernetes-authenticator` is a small application/container that performs the [HashiCorp Vault][vault] [kubernetes authentication process][vault-k8s-auth] and places the Vault token in a well-known, configurable location. It is most commonly used as an init container to supply a Vault token to applications or services that are unaware of Vault.

[vault]: https://www.vaultproject.io
[vault-k8s-auth]: https://www.vaultproject.io/docs/auth/kubernetes.html#authentication


## Configuration

- `VAULT_ADDR` - the address to the Vault server, including the protocol and port (like `https://my.vault.server:8200`). This defaults to `https://127.0.0.1:8200` if unspecified.

- `VAULT_CAPEM` - the raw PEM contents of the CA file to use for SSL verification.

- `VAULT_CACERT` - the path on disk to a single CA file to use for TSL verification.

- `VAULT_CAPATH` - the path on disk to a directory of CA files (non-recursive) to use for TLS verification.

- `VAULT_SKIP_VERIFY` - disable SSL validation (not recommended)

- `VAULT_ROLE` - **Required** the name of the Vault role to use for authentication.

- `VAULT_NAMESPACE` - the [Vault namespace](https://www.vaultproject.io/docs/enterprise/namespaces/index.html#usage), only available in Vault Enterprise

- `TOKEN_DEST_PATH` - the destination path on disk to store the token. Usually this is a shared volume. Defaults to `/var/run/secrets/vaultproject.io/.vault-token`.

- `ACCESSOR_DEST_PATH` - the destination path on disk to store the accessor. Usually this is a shared volume. Defaults to `/var/run/secrets/vaultproject.io/.vault-accessor`.

- `SERVICE_ACCOUNT_PATH` - the path on disk where the kubernetes service account jtw token lives. This defaults to `/var/run/secrets/kubernetes.io/serviceaccount/token`.

- `VAULT_K8S_MOUNT_PATH` - the name of the mount where the Kubernetes auth method is enabled. This defaults to `kubernetes`, but if you changed the mount path you will need to set this value to that path.

  ```text
  vault auth enable -path=k8s kubernetes -> VAULT_K8S_MOUNT_PATH=k8s
  ```

## Example Usage

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-auther
spec:
  securityContext:
    runAsUser: 1001
    fsGroup: 1001

  volumes:
  - name: vault-auth
    emptyDir:
      medium: Memory
  - name: vault-secrets
    emptyDir:
      medium: Memory

  initContainers:
  - name: vault-authenticator
    image: sethvargo/vault-kubernetes-authenticator:0.2.0
    imagePullPolicy: Always
    volumeMounts:
    - name: vault-auth
      mountPath: /var/run/secrets/vaultproject.io
    env:
    - name: VAULT_ROLE
      value: myapp-role
    securityContext:
      allowPrivilegeEscalation: false

  containers:
    # Your other containers would read from /home/vault/.vault-token, or set
    # HOME to /home/vault
  - name: consul-template
    image: hashicorp/consul-template:0.19.5.alpine
    volumeMounts:
    - name: vault-auth
      mountPath: /home/vault
    - name: vault-secrets
      mountPath: /var/run/secrets/vaultproject.io
    env:
    - name: HOME
      value: /home/vault

  # ...
```
