# vault-kubernetes-authenticator

The `vault-kubernetes-authenticator` is a small application/container that performs the [HashiCorp Vault][vault] [kubernetes authentication process][vault-k8s-auth] and places the Vault token in a well-known, configurable location. It is most commonly used as an init container to supply a Vault token to applications or services that are unaware of Vault.

[vault]: https://www.vaultproject.io
[vault-k8s-auth]: https://www.vaultproject.io/docs/auth/kubernetes.html#authentication


## Configuration

- `VAULT_ADDR` - the address to the Vault server, including the protocol and port (like `https://my.vault.server:8200`). This defaults to `https://127.0.0.1:8200` if unspecified.

- `VAULT_CACERT` - the raw PEM contents of the CA file to use for SSL verification. If left unspecified, the system roots are used.

- `VAULT_CAPATH` - the path on disk to the contents of the CA file to use for SSL verification. If left unspecified, the system roots are used.

- `VAULT_ROLE` - **Required** the name of the Vault role to use for authentication.

- `TOKEN_DEST_PATH` - the destination path on disk to store the token. Usually this is a shared volume. Defaults to `/.vault-token`.

- `SERVICE_ACCOUNT_PATH` - the path on disk where the kubernetes service account jtw token lives. This defaults to `/var/run/secrets/kubernetes.io/serviceaccount/token`.

## Example Usage

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-sidecar
spec:
  volumes:
  - name: vault-token
    emptyDir: {}

  initContainers:
  # The vault-authenticator container authenticates the container using the
  # kubernetes auth method and puts the resulting token on the filesystem.
  - name: vault-authenticator
    image: sethvargo/vault-kubernetes-authenticator:0.1.0
    volumeMounts:
    - name: vault-token
      mountPath: /home/vault
    env:
    - name: TOKEN_DEST_PATH
      value: /home/vault/.vault-token
    - name: VAULT_ROLE
      value: myapp-role

  containers:
    # Your other containers would read from /home/vault/.vault-token, or set
    # HOME to /home/vault
  - name: consul-template
    image: hashicorp/consul-template:0.19.5.alpine
    volumeMounts:
    - name: vault-token
      mountPath: /home/vault
    env:
    - name: HOME
      value: /home/vault

  # ...
```
