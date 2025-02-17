# bridget
"My" script for setting up a routing vm for personal projects
Big thanks and lots of love to all ppl in linked threads for finding such solutions, u're truly wonderful ❤️
Tested on Alpine Linux 3.21
# Requirements
- Bash > 4.3
# Installation
Just clone repo and put iptables.sh under **/etc/network/if-post-up.d/**:
```
git clone https://github.com/kotsyubin/bridget.git && sudo cp ./bridget/iptables.sh /etc/network/if-post-up.d/ && sudo chmod +x /etc/network/if-post-up.d/iptables.sh
```