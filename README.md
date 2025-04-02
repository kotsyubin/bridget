# bridget
My collection of shell scripts for:
- Setting up a routing vm for personal projects (iptables.sh)
- Setting up opentofu with locally installed providers on machine without sudo access (tofu.sh)

Big thanks and lots of love to all ppl in linked threads for finding such solutions, u're truly wonderful ❤️

Tested on:
| Distro | Release | Result |
| ----------- | ----------- | ----------- |
| Alpine Linux | 3.21 | ✅ |
| Ubuntu | 22.04.5 | ✅ |
# Requirements
- Bash > 4.3
# Installation
Clone repo first:
```
git clone https://github.com/kotsyubin/bridget.git
``` 
## iptables.sh
Just put iptables.sh under **/etc/network/if-post-up.d/** (or whatever your distro calls it) and make executable:
```
git clone https://github.com/kotsyubin/bridget.git &&\
sudo cp ./bridget/iptables.sh  /etc/network/{if-post-up.d,if-up.d}/ &&\
sudo chmod +x /etc/network/{if-post-up.d,if-up.d}/iptables.sh
```
## tofu.sh
Make it executable and run, that's all:
```
chmod +x ./bridget/tofu.sh && ./bridget/tofu.sh
```
