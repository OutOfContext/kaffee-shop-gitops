# Secrets-Demo (Tag 2, Modul 11)

Hier landet das **SealedSecret**, das Sie in der Übung mit `kubeseal` erzeugen.
Es enthält KEINEN Klartext und darf deshalb in Git liegen.

Ablauf:
1. Sealed-Secrets-Controller per Argo CD-Application aus dem Helm-Chart installieren.
2. `kubeseal --fetch-cert > pub-cert.pem`
3. `kubectl create secret generic shop-db --dry-run=client --from-literal=password=... -o yaml | kubeseal --cert pub-cert.pem -o yaml > shop-db.sealed.yaml`
4. Commit, Push, Sync.
