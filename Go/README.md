# GOPATH and module
GOROOT = where Go is installed
GOPATH = Where go code resides

## Initialize mod
Go Modules were introduced in Go 1.11 and enabled by default from 1.13.
With Go Modules, you can store your code anywhere on your system.

Initialize a go module:
```
go mod init testHello
```

Create a new Go file


## Go also can import remote modules use 
```
import (
    "<remote url>"
)
```

Get the remote module to import it. Use CLI to get it from remote
```
go get <remote url>
```

