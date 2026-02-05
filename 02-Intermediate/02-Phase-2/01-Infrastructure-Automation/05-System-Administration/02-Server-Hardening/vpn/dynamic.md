## Important notes before running
Script assumes a fresh Debian/Ubuntu server (Ubuntu 20.04/22.04/24.04 tested). If you need CentOS/RHEL/Alma/ Rocky, tell me and I’ll adapt it.
You must run as root (or sudo). Script touches /etc/wireguard, sysctl, iptables/nftables and systemd.
This script uses wg / wg-quick + iptables NAT. It supports adding peers dynamically using wg set (no service restart).

## Why this design & operational notes (short)
Dynamic peers: wg set wg0 peer <pubkey> allowed-ips <ip> adds peers at runtime without restarting wg-quick or dropping existing sessions. This is how we keep it dynamic. (See community discussions and ubuntu docs). 
Server Fault
+1
Persistence: We append [Peer] blocks into /etc/wireguard/wg0.conf when adding so that reboot restores the state (SaveConfig = true helps, but explicit persistence avoids surprises).
NAT & forwarding: sysctl and iptables MASQUERADE lines in PostUp/PostDown route client traffic out the server’s primary interface. For nftables, you must adapt those rules. 
DigitalOcean
QR codes: qrencode is optional but handy for mobile onboarding.
Security: Keys are generated with wg genkey and files are created with umask 077. For higher-security environments, put keys on an HSM or dedicated secret store.
Public IP detection: The script attempts to auto-detect the out interface and a local IP; if the server is behind NAT (common in cloud/ISP setups), you should set BACKEND_IP explicitly to your server's public-facing IP or use a dynamic DNS name.

## Caveats / Next steps I recommend
Cloud provider firewall rules: Open UDP port ${PORT} on your cloud provider security group (AWS SG, GCP firewall, Azure NSG, etc.).
Auditing & rotation: Add logging + rotate keys periodically. For government/high-security environments, integrate with a PKI or a secrets manager.
nftables: If your distro uses nftables by default, substitute the iptables NAT in PostUp/PostDown. I can produce the nftables equivalents.
Multi-protocol support: If you need OpenVPN or IKEv2 (strongSwan) for legacy clients, I can add a combined installer. Reference OpenVPN and strongSwan official/how-to guides for production setups. 
DigitalOcean
+1

## Citations / references (key docs I used)
WireGuard Quickstart (official). 
wireguard.com
Ubuntu WireGuard docs / common tasks (wg-quick, runtime operations). 
Ubuntu Documentation
Discussion on adding/removing peers at runtime (no restart). 
Server Fault
DigitalOcean / Ubuntu OpenVPN and strongSwan tutorials for multi-protocol background reading. 
DigitalOcean
+1

## Questions for you (to refine / harden / extend)
(Answer any subset — but I’ll proceed with sensible defaults if you don’t reply.)
Which Linux distribution(s) & versions will you deploy this on? (Ubuntu 22.04? 24.04? RHEL/CentOS?)
Will the server have a public IPv4 address, or be behind NAT/CGNAT (cloud LB, or corporate NAT)? If behind NAT, do you use a static public IP or dynamic DNS?
Do you prefer WireGuard only (recommended) or must we also provide OpenVPN and IKEv2/strongSwan in the same script? (I can add them, but it increases complexity & length.)
Do you want client configs restricted to split-tunnel (only certain CIDRs) or default route (0.0.0.0/0)? The script uses default route for clients by default.
Any enterprise requirements: logging, central auth (RADIUS/LDAP), PKI integration, HSM, or automatic key rotation?

If you’d like, I can:
adapt this script for Alma/RHEL/CentOS, or for nftables instead of iptables,
extend it to provision OpenVPN (EasyRSA) or strongSwan IKEv2 in same installer,
or harden it to meet specific compliance (FIPS, STIG-style controls) — tell me which controls.

Want me to:
produce the nftables variant now?
add an OpenVPN install path to the same script?
or tailor this script for a specific distro/cloud provider and produce a ready-to-run unit with comments and audit checks?