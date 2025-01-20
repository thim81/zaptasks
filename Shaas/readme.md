### Shaas

Shell as service, API to inspect and execute scripts in a server's environment via HTTP and WebSockets.

### Run Shaas service

To start the shaas service, just initiate the command

```shell
./shaas 
```

Which runs by default on port 7575

To start the service on a certain port


```shell
PORT=6666 ./shaas
```

or 

```shell
./shaas --port 6666
```