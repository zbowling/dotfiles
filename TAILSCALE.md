# Tailscale Setup

Tailscale creates a secure mesh VPN between your devices. After installing via `--tailscale`, follow these steps.

## Quick Start

```bash
# Connect to your tailnet
sudo tailscale up

# Authorize in browser when prompted
# Your device will appear at https://login.tailscale.com/admin/machines
```

## Basic Commands

```bash
# Check status
tailscale status

# See your Tailscale IP
tailscale ip

# Ping another device
tailscale ping <device-name>

# SSH to another device (if SSH enabled)
ssh user@<device-name>
```

## Features

### MagicDNS

Access devices by name instead of IP:

```bash
# Instead of:
ssh user@100.64.0.1

# Use:
ssh user@my-laptop
```

Enable in: Admin Console > DNS > Enable MagicDNS

### Tailscale SSH

Let Tailscale handle SSH authentication (no keys needed):

```bash
# Enable on a device
sudo tailscale up --ssh

# SSH without managing keys
ssh my-server
```

Enable in: Admin Console > Settings > Tailscale SSH

### Exit Nodes

Route all traffic through another device:

```bash
# On the exit node (e.g., home server)
sudo tailscale up --advertise-exit-node

# On the client (e.g., laptop on public wifi)
sudo tailscale up --exit-node=<exit-node-name>

# Stop using exit node
sudo tailscale up --exit-node=
```

Approve exit node in: Admin Console > Machines > [...] > Edit route settings

### Subnet Routing

Access your home network from anywhere:

```bash
# On a device in your home network
sudo tailscale up --advertise-routes=192.168.1.0/24

# Approve in admin console, then access from anywhere
ping 192.168.1.50
```

## Troubleshooting

### Connection Issues

```bash
# Check if Tailscale daemon is running
systemctl status tailscaled

# Restart if needed
sudo systemctl restart tailscaled

# Re-authenticate
sudo tailscale up --force-reauth
```

### Firewall Issues

Tailscale uses UDP 41641. Most firewalls don't need configuration, but if having issues:

```bash
# Check connection type
tailscale status --peers

# Should show "direct" for nearby peers
# "relay" means going through DERP (slower but works)
```

### Logs

```bash
# View Tailscale logs
journalctl -u tailscaled -f
```

## Admin Console

Manage your tailnet at: https://login.tailscale.com/admin

- **Machines**: See all connected devices
- **Users**: Manage team access
- **DNS**: Configure MagicDNS and nameservers
- **ACLs**: Fine-grained access control (JSON policy)
- **Settings**: Enable features like SSH, exit nodes

## Useful Links

- [Tailscale Docs](https://tailscale.com/kb/)
- [Admin Console](https://login.tailscale.com/admin)
- [ACL Examples](https://tailscale.com/kb/1018/acls/)
