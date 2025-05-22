## Setup htpasswd identity provider 



- [ ]    Create password file
```
-c creates new file, -b appends following users
```
```
$ cd "directory"

$ htpasswd -c -B -b htpasswd user1 Password1

$ htpasswd -b htpasswd user2 Password2

$ htpasswd -b htpasswd user3 Password3

$ htpasswd -b htpasswd user4 Password4

$ htpasswd -b htpasswd user5 Password5
```

- [ ]    Create Secret

```
  oc create secret generic htpass-secret --from-file=htpasswd=./htpasswd -n openshift-config
```

- [ ]    Create a custom resource (CR). Save the following contents in a file:
```  
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
```

- [ ]    Apply the CR by running the following command:
```
oc apply -f <file name>
```

- [ ]    Log in as a user created with htpasswd:
```
oc login -u <username>
```
