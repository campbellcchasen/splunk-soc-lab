# Linux Universal Forwarder Setup

This documents how the Linux Mint VM was connected to the Splunk Enterprise instance
running on the Windows host, so that `/var/log/auth.log` events could be ingested
for the SSH brute-force and privilege-escalation detections.

## Environment
- Kali Linux (attacker) and Linux Mint (target) VMs in VirtualBox, both on a
  Bridged Adapter so they share the host's home network.
- Splunk Enterprise on the Windows host, receiving on TCP 9997.

## Steps

1. Create the index. In Splunk Web: Settings > Indexes > New Index, named `linuxlogs`.
2. Enable receiving. Settings > Forwarding and receiving > Configure receiving >
   New Receiving Port > `9997`.
3. Open the firewall on the Windows host for the home subnet:
   `netsh advfirewall firewall add rule name="Splunk Receiving 9997" dir=in action=allow protocol=TCP localport=9997 remoteip=192.168.1.0/24`
4. Install the Universal Forwarder on Mint (free download, splunk.com account required):
   `sudo dpkg -i splunkforwarder-*.deb`
   `sudo /opt/splunkforwarder/bin/splunk start --accept-license`
5. Point the forwarder at the indexer:
   `sudo /opt/splunkforwarder/bin/splunk add forward-server 192.168.1.85:9997`
6. Monitor the auth log:
   `sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/auth.log -index linuxlogs -sourcetype linux_secure`
7. Verify with `splunk list forward-server` (should show the server under
   Active forwards) and a search for `index=linuxlogs` in Splunk Web.

## Lessons learned
- VirtualBox's NAT Network lets the attack and target VMs reach each other, but
  not the host, so a Bridged Adapter was used instead to give both VMs a route
  back to the Windows host running Splunk.
- The Linux `sudo` session-opened event is also logged by cron jobs running as
  root, so the privilege-escalation detection filters out `sudo_user=root` to
  avoid false positives from scheduled tasks.
- Installing SSH and the forwarder itself creates local service accounts
  (`sshd`, `splunkfwd`), which the new-user detection filters out to avoid
  noise.
