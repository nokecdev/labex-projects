# Network Service Challenge (CTF)
 Connect to the suspicious network service running on localhost and capture the flag it reveals. This challenge is designed for advanced users who know their way around Linux networking tools, with no hints provided to test your expertise.

Steps:
1. nmap localhost
This command will reveal port 12345
2. Check with curl:
curl -i localhost:12345
This will throw error: Received HTTP/0.9 when not allowed
3. Try with netcat:
nc localhost 12345
4. Flag revealed.

# Web Input Vulerability (CTF)
1. nmap localhost
2. curl -i localhost:9000
3. curl -i localhost:9000
```
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.10.12
Date: Tue, 24 Feb 2026 20:21:42 GMT
Content-type: text/html; charset=utf-8
Content-Length: 1263

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Directory listing for /</title>
</head>
<body>
<h1>Directory listing for /</h1>
<hr>
<ul>
<li><a href=".ICE-unix/">.ICE-unix/</a></li>
<li><a href=".X1-lock">.X1-lock</a></li>
<li><a href=".X11-unix/">.X11-unix/</a></li>
<li><a href=".xfsm-ICE-397QK3">.xfsm-ICE-397QK3</a></li>
<li><a href="form.html">form.html</a></li>
<li><a href="HoFELVXC/">HoFELVXC/</a></li>
<li><a href="hsperfdata_root/">hsperfdata_root/</a></li>
<li><a href="labex-code-server-zsh/">labex-code-server-zsh/</a></li>
<li><a href="pwlPjBRA/">pwlPjBRA/</a></li>
<li><a href="server.py">server.py</a></li>
<li><a href="session/">session/</a></li>
<li><a href="ssh-XXXXXXhUDDiW/">ssh-XXXXXXhUDDiW/</a></li>
<li><a href="tmux-5000/">tmux-5000/</a></li>
<li><a href="vscode-git-11ab6f613c.sock">vscode-git-11ab6f613c.sock</a></li>
<li><a href="vscode-ipc-ba8181b3-cb2e-410d-b245-415bfb9ade0b.sock">vscode-ipc-ba8181b3-cb2e-410d-b245-415bfb9ade0b.sock</a></li>
<li><a href="vscode-ipc-ef09778b-ab3b-47dc-b005-cdbac3235c21.sock">vscode-ipc-ef09778b-ab3b-47dc-b005-cdbac3235c21.sock</a></li>
</ul>
<hr>
</body>
</html>
```

This will reveal it has a form.html view. Let's see:
4. curl -i localhost:9000/form.html
```
labex:project/ $ curl -i localhost:9000/form.html
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.10.12
Date: Tue, 24 Feb 2026 20:23:19 GMT
Content-type: text/html
Content-Length: 335
Last-Modified: Tue, 24 Feb 2026 20:10:46 GMT

<!DOCTYPE html>
<html>
<head>
    <title>Secret Form</title>
</head>
<body>
    <h1>Enter the Secret Code</h1>
    <form action="/form.html" method="post">
        <label for="secret">Secret:</label>
        <input type="text" id="secret" name="secret"><br><br>
        <input type="submit" value="Submit">
    </form>
</body>
</html>
```

5. Use curl with post (-d) request to find out the secret
curl -d secret=unlock -i localhost:9000/form.html

6.
labex:project/ $ curl -d secret=unlock -i localhost:9000/form.html
HTTP/1.0 200 OK
Server: SimpleHTTP/0.6 Python/3.10.12
Date: Tue, 24 Feb 2026 20:21:16 GMT
Content-type: text/html

Success! Here is your flag: FLAG{WebInput010} 