## Setup htpasswd identity provider 

- [ ] Install httpd-tools

```
yum install httpd-tools
```

- [ ]    Create users with password file
-c creates new file, -b appends following users

```
htpasswd -c -B -b htpasswd user1 Password1
htpasswd -b htpasswd user2 Password2
htpasswd -b htpasswd user3 Password3
htpasswd -b htpasswd user4 Password4
htpasswd -b htpasswd user5 Password5
```
<img width="1368" alt="image" src="https://github.com/user-attachments/assets/8b7583e6-8abc-4acc-962c-663ac574083d" />

<img width="1209" alt="image" src="https://github.com/user-attachments/assets/e2fc1a54-ef8c-419b-b07e-fb252fc6771f" />


- [ ]   Log into OCP cluster and Create the Secret

```
  oc create secret generic htpass-secret --from-file=htpasswd=./htpasswd -n openshift-config
```
<img width="1332" alt="image" src="https://github.com/user-attachments/assets/2859723a-4ef4-49e8-8016-21b4e0f88e74" />


<img width="1332" alt="image" src="https://github.com/user-attachments/assets/243ae2d5-055c-4df7-9427-decf942c4cc4" />


- [ ]    Create a custom resource (CR) OAuth object
Save the following contents in a file:
```
cat > htpasswd.yaml << EOF 
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
EOF
```
<img width="694" alt="image" src="https://github.com/user-attachments/assets/763473ff-4756-4315-a2ae-cf84ec5ac86d" />

- [ ]    Apply the CR by running the following command:
```
oc apply -f htpasswd.yaml
```
<img width="1373" alt="image" src="https://github.com/user-attachments/assets/fe7b5350-da2b-4d09-94c1-5d19b3e3ecf0" />

<img width="1491" alt="image" src="https://github.com/user-attachments/assets/e56e27f4-6fff-4580-b86c-d293292893bb" />


- [ ]    Log in as a user created with htpasswd:
```
oc login -u <username>
```

<img width="694" alt="image" src="https://github.com/user-attachments/assets/30c02fbc-b852-4825-b32d-d15503f078c7" />


<img width="694" alt="image" src="https://github.com/user-attachments/assets/59280fa5-675c-4e3a-b44e-00193ca4ac60" />


## How to generate htpasswd file for appending more users

Log in to the cluster as a cluster-admin and retrieve the secret as a file.
```
oc get secret htpass-secret -ojsonpath={.data.htpasswd} -n openshift-config | base64 --decode > test.htpasswd
```

<img width="1212" alt="image" src="https://github.com/user-attachments/assets/111f5f8f-b403-4f3e-955c-24a019ed44fc" />


On successful creation, please delete the local password file.
