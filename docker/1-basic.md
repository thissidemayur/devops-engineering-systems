# Docker FOundations and understanding

## Contianer

it is the process on the host, isolated using linux primitives(namespace + cgroups) with layerd filesystems(overlays)

## Commands

 ```bash

 docker run -d -p 8080:80 --name mynginx nginx
 ```

Internally:

1. Check image locally:
    - if not present then pull from regiestery
2. Create container (not start yet)
    - allocate containerId
    - setup metadata
3. Setup filesystem:
    - stack image layers
    - add writeable layer (overlayers)
4. setup namespace:
    - PID namespace (isloated process tress)
    - NET namespace (separate network)
    - MNT namespace (filesystem isloation)
5. setup cgroups
    - resource limits (cpu,memory)
6. port mapping
    - iptable rule created .

    ```
    host:8080 - > container_ip:80
    ```

7. start process:
    - run nginx as PID 1 inside container.

**attach and isloated mode**

1. -d (detached):
run container in background and our present terminal freed
2. -it (intereactive _ ttly):
attach our terminal to container stdin/stdout
used for shell

### 1. Where container actually run?

container is process on host OS
there fore it shares kernal
and isolation is done using:
    - namespace: isloation
    - cgroups: resource controlls

### 2.  What does -p 8080:80 actually do internally?

docker add iptable NAT rule.

```bash
HOST: 8080 -> COntainerIP:80
```

so when user request comes:

```
localhost:8080
    ↓
iptable rule
    ↓
container_ip:80
    ↓
nginx
```

### 3. What filesystem does this container see?how is it constructed?

whatever we write using docker container it add on image layer stack of image

a merged filesystem:

```
Writable layer (container)
-------------------------
Image layer 3
Image layer 2
Image layer 1
```

using overlays

---

```bash
docker exec -it mynginx bash

```

- exec -> run new process inside contianer
- bash -> the process we are starting.
means we are saying start a bash shell inside this container.

then inside contianer:
```
touch test.txt
```

### 1. Where is test.txt actually stored?

File is stored in container writeable layer (not in host filesystem directly)

### 2. Which layer got modified?

    container writetale layer (tpp layer)

---
