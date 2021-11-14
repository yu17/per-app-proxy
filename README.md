# Per-App-Proxy

## Usage

### Prerequisites

These scripts make use of existing socks proxy and channels the packets from selected apps into the socks proxy. Therefore, you'll need a socks proxy setup before using this script.

Besides, you need to install `badvpn`.

### Run the scripts

First, run `relay_tun_setup.sh` with the user under which your app is running. Then, run `badvpn_tun2socks_client.sh` in a seperate shell and keep it running. (Or run in the background and channel all its output to /dev/null.) Finally, run `relay_tun_addproc.sh` with the process name so it will add all the processes that contains the provided process name in its command to the channeled process list.
