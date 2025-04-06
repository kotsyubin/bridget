#!/bin/bash
lbin=$HOME/.local/bin
pldir=$HOME/.terraform.d/plugins/tofu.local/local
   
declare -A plugins=(
    [virtualbox]="github.com/terra-farm/terraform-provider-virtualbox 0.2.2-alpha.1 terraform-provider-virtualbox"
    [opennebula]="github.com/OpenNebula/terraform-provider-opennebula 1.4.1 terraform-provider-opennebula"
    [virtualbox]="github.com/daria-barsukova/terraform-provider-virtualbox 0.0.2 terraform-provider-virtualbox"
    [vmmanager6]="github.com/usaafko/terraform-provider-vmmanager6 0.0.34 terraform-provider-vmmanager6"
    )
 
function main {
    [ -z "$1" ] && { one; two; } || $1    
}
 
function create_tofurc() {
echo "provider_installation {
    network_mirror {
    url = \"https://terraform-mirror.yandexcloud.net/\"
    include = [\"registry.opentofu.org/*/*\"]
    }
    filesystem_mirror {
        path = \"`echo $HOME`/.terraform.d/plugins\"
        include = [\"tofu.local/*/*\",\"registry.opentofu.org/*/*\"]
    }
    direct {
        exclude = [\"tofu.local/*/*\",\"registry.opentofu.org/*/*\"]
    }
    }" > ~/.tofurc
}
 
function prepare_env() {
    mkdir -p $lbin
    tee -a ~/.bashrc <<< "export PATH=$PATH:$lbin"
    source ~/.bashrc
    mkdir -p $pldir
    create_tofurc
}
  
function setup_tofu() {
    cd $lbin
    wget "https://github.com/opentofu/opentofu/releases/download/v1.9.0/tofu_1.9.0_$(uname | tr A-Z a-z)_amd64.zip"
    unzip -op tofu* tofu > tofu
    chmod +x tofu
    rm tofu*.zip
}
  
function setup_plugins() {
    for i in "${!plugins[@]}";
        do
        plugin_name=$(cut -d' ' -f3 <<< ${plugins[$i]})
        plugin_version=$(cut -d' ' -f2 <<< ${plugins[$i]})
        plugin_repo=$(cut -d' ' -f1 <<< ${plugins[$i]})
        file=
            echo "Creating $pldir/$i/$plugin_version/$(uname | tr A-Z a-z)_amd64"
            mkdir -p $pldir/$i/$plugin_version/$(uname | tr A-Z a-z)_amd64
            cd $pldir/$i/$plugin_version/$(uname | tr A-Z a-z)_amd64
            wget "https://$plugin_repo/releases/download/v$plugin_version/${plugin_name}_${plugin_version}_$(uname | tr A-Z a-z)_amd64.zip"
            unzip -o *.zip
            rm *.zip
    done
}
  
main "$@"
