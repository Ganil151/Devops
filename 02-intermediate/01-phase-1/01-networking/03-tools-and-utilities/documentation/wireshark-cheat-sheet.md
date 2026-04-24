# í¶ˆ Wireshark Display Filter Cheat Sheet

| Goal | Filter |
| :--- | :--- |
| Show only HTTP | `http` |
| Show traffic to specific IP | `ip.addr == 10.0.1.5` |
| Show only TCP Syn packets | `tcp.flags.syn == 1` |
| Find HTTP 404 errors | `http.response.code == 404` |
| Filter by Port | `tcp.port == 8080` |
