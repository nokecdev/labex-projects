===== Server Connectivity Monitor =====
Started at: Tue Mar 28 13:15:01 UTC 2023

Testing https://www.google.com:
✓ Status: 200 (OK)
• Response time: 0.186s
• Server headers:
  Date: Tue, 28 Mar 2023 13:15:02 GMT
  Content-Type: text/html; charset=ISO-8859-1
  Server: gws

Testing https://www.github.com:
✓ Status: 200 (OK)
• Response time: 0.247s
• Server headers:
  Server: GitHub.com
  Date: Tue, 28 Mar 2023 13:15:02 GMT
  Content-Type: text/html; charset=utf-8

Testing https://www.example.com:
✓ Status: 200 (OK)
• Response time: 0.132s
• Server headers:
  Content-Type: text/html; charset=UTF-8
  Date: Tue, 28 Mar 2023 13:15:03 GMT
  Server: ECS (nyb/1D2B)

Testing https://httpbin.org/status/404:
✗ Status: 404 (Client Error)
• Response time: 0.189s
• Server headers:
  Date: Tue, 28 Mar 2023 13:15:03 GMT
  Content-Type: text/html; charset=utf-8
  Server: gunicorn/19.9.0

Testing https://httpbin.org/status/500:
✗ Status: 500 (Server Error)
• Response time: 0.192s
• Server headers:
  Date: Tue, 28 Mar 2023 13:15:03 GMT
  Content-Type: text/html; charset=utf-8
  Server: gunicorn/19.9.0

===== Monitoring Complete =====
Finished at: Tue Mar 28 13:15:04 UTC 2023