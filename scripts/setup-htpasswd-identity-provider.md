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


# Troubleshooting

## How to generate htpasswd file for appending more users

* Log in to the cluster as a cluster-admin and retrieve the secret as a file.
```
oc get secret htpass-secret -ojsonpath={.data.htpasswd} -n openshift-config | base64 --decode > test.htpasswd
```
<img width="1186" alt="image" src="https://github.com/user-attachments/assets/a036fb68-4f68-4cb3-b682-550286f909d7" />

* Add password to the htpasswd file
```
htpasswd -b htpasswd user6 Password6
```
<img width="713" alt="image" src="https://github.com/user-attachments/assets/997cbaf8-c9ae-4d6a-8625-11115ab8bda4" />


* Replace the htpass-secret Secret object with the updated users in the htpasswd file:
```
oc create secret generic htpass-secret --from-file=htpasswd=./htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -
```

<img width="1309" alt="image" src="https://github.com/user-attachments/assets/17b04d2b-f67b-4789-928e-76bbb012a015" />


* Verify

<img width="1309" alt="image" src="https://github.com/user-attachments/assets/6d759bc7-1d89-4b82-a53f-1c48443a807b" />

On successful creation, please delete the local password file.

## How to replace oAuth ?

```
oc replace -f oauth.yaml

example:
oc replace -f htpasswd.yaml
```

## How to delete a user ?

Example delete user6

* Delete the user from the htpasswd file
```
cat htpasswd
htpasswd -D htpasswd user6
```
<img width="560" alt="image" src="https://github.com/user-attachments/assets/252ae66b-db8c-48bb-adb1-206f6720dfbc" />

* Update the secret

```
oc create secret generic htpass-secret --from-file=htpasswd=htpasswd --dry-run=client -o yaml -n openshift-config | oc replace -f -
```
* Verify the user6 is deleted in secret
<img width="1493" alt="image" src="https://github.com/user-attachments/assets/dd542d1d-9498-4a65-91f4-0b152832c6a0" />

* Remove resources
```   
If you removed one or more users, you should also remove existing resources for each user.

Example:

 oc delete user user6
```

<img width="498" alt="image" src="https://github.com/user-attachments/assets/36725309-8488-4b63-b9a9-123810b2a60b" />

```
oc delete identity htpasswd:user6
```
<img width="498" alt="image" src="https://github.com/user-attachments/assets/e77352a0-e8f2-4571-bb06-d9c77ffeb725" />

* Verify login for the deleted user
```
oc login -u user6 -p Password6
```
  <img width="1186" alt="image" src="https://github.com/user-attachments/assets/fd438f01-20a6-40d7-acb8-6b7f86d5d1e0" />
