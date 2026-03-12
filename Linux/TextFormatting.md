I have the following hydra output, and I want to save it into a file for later in the following structure: username:password

```
labex:project/ $ cat hydra_output.txt
# Hydra v9.2 run at 2026-03-12 23:35:34 on 127.0.0.1 telnet (hydra -L usernames.txt -P passwords.txt -o hydra_output.txt telnet://127.0.0.1)
[23][telnet] host: 127.0.0.1   login: user1   password: password
[23][telnet] host: 127.0.0.1   login: user2   password: 123456
[23][telnet] host: 127.0.0.1   login: user3   password: qwerty
```

For this use the grep command with regex:
```
grep "login:" hydra_output.txt | sed -E 's/.*login: ([^ ]+).*password: ([^ ]+)/\1:\2/' > credentials.txt
```

Result:
```
labex:project/ $ cat credentials.txt
user1:password
user2:123456
user3:qwerty
```
