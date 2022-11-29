# ipfs-pinner
- a wrapper on top of ipfs node, utilising go-ipfs as a library.
- extended support for custom file upload endpoints provided by pinata & web3.storage
- content archive file generation and lightweight deterministic CID generation on client side (using CARs).
- it can be used as a go library (see `binary/main.go` for usage) or as a http server


## Usage as a library

Create a `PinnerNode` and start utilizing the services it is composed of. Check `binary/main.go` for detailed usage.

### A note on CID and CAR files

When you do a `ipfs add`, the content of the files are chunked and a merkle DAG is converted which is used to compute the root CID. Now there are various parameters which can determine the structure of the DAG (see `ipfs help add`), and using different parameters results in different CIDs. As an example, web3.storage and pinata reported different CIDs for files greater than 256KB, because web3.storage used chunked the data at 1 MB while pinata used the default value (256Kb).

To avoid this issue, the merkle DAG thus generated is exported into special files called content archives, and uploading these CAR files. Thus, the merkle DAG structure is encapsulated in the files uploaded, and the same CID can now be used no matter what the pinning service is.


## Usage as a server

ipfs-pinner can be run as a server and allows two functionalities currently - `/get` and `/upload`

to start a server which listens for request on a particular port, run:
```bash
make clean server-dbg run
```


### upload a file
- submit a request to upload a file (using multipart/form-data):
```bash
➜ curl -F "filedata=@file_to_upload" http://127.0.0.1:3000/upload
{"cid": "QmUqcL1RwbnbQ3FzmnT1aeRk8g8L5naKinJd5hCuPXxbZ2"}
```

- failures will be reported (via "error" field in the json). E.g:
```bash
➜ curl -F "filedata=@non_existent_file" http://127.0.0.1:3000/upload
{"error": "open not_exist_file: no such file or directory"}
```

there's a timeout (check code for value), on timeout the error message returned is:
```bash
{"error": "context deadline exceeded"}
```


### download content (given cid)
- download a file
if the request succeeds the raw content is sent back and it can be outputted in a file using curl. e.g.
```bash
➜ curl -XGET http://127.0.0.1:3000/get\?cid\=bafybeifzst7cbujrqemiulznrkttouzshnqkrajiib5fp5te53ojs5sl5u --output file.jpeg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  806k    0  806k    0     0  91.2M      0 --:--:-- --:--:-- --:--:--  262M
```

Now, if the data is present in local ipfs store, it'll be returned from there. Otherwise, it has to interact with other IPFS peers to find 
and fetch the data.
There's a timeout (check code for value) for the download request, if it doesn't succeed in that time, the error message returned is:
```bash
{"error": "context deadline exceeded"}
```

### find the cid given some content
```bash
➜ curl -F "filedata=@LICENSE" http://127.0.0.1:3000/cid
{"cid": "bafkreicszve3ewhhrgobm366mdctki2m2qwzide5e54zh5aifnesg3ofne"}%
```

## running ipfs-pinner server on docker

We can also run the ipfs-pinner server via docker.
for ipfs-pinner to function properly with docker, we need
- docker volumes, to host the added data and persist it across container restarts/kill etc.
- expose the ports that ipfs needs from the docker.

docker run command should have:
- volumes for data persistence
- port mappings
- jwt token passed in the env


```bash
docker image build --tag ipfs-pinner:latest  .
```

Now, we can run the container:

```bash
docker container run --detach --name ipfs-pinner-instance \
       --volume /tmp/data/.ipfs/:/root/.ipfs/  \
       -p 4001:4001 -p 3000:3000  \
       --env WEB3_JWT=$WEB3_JWT \
    <container-image-id>
```


### Notes on Docker Volume setup

There's 1 docker volumes that need to be shared (and persisted) between the container and the host - the .ipfs directory needs to have its lifecycle unaffected by container lifecycle (since it contains the merklelized nodes, blockstore etc.), and so that is docker volume managed.  

### Notes on port mapping setup

:4001 : swarm port for p2p  
:8080 - http gateway (used by encapsulated ipfs-node)
:5001: local api (should be bound to 127.0.0.1 only, and must never be exposed publically as it allows one to control the ipfs node; also used by encapsulated ipfs-node)  
:3000: The ipfs-pinner itself exposes its REST API on this port

<B>Out of the above, only the swarm port and the REST api port (3000) are essential.</B>  

---

## Development

### generate go http client go bindings via openapi
- use `./generate_gobindings.sh` to generate the golang bindings (for pinning services of pinata and web3.storage). 
- There are some fixes you would need to do (missing braces etc.)
