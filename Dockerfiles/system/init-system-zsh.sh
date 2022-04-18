#!/bin/bash
set -euxo pipefail

rm -rf /root/.oh-my-zsh
yum -y install zsh

## online install
# zsh_install_tmp_script=/tmp/install.sh
# echo "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" > $zsh_install_tmp_script

# sed -i "s/REPO=.*/REPO=\${REPO:-ohmyzsh\/ohmyzsh}/g" $zsh_install_tmp_script
# sed -i "s/REMOTE=.*/REMOTE=\${REMOTE:-https:\/\/gitee.com\/\${REPO}.git}/g" $zsh_install_tmp_script
# echo Y | sh $zsh_install_tmp_script
# rm -f $zsh_install_tmp_script

## offline install
pushd /tmp
curl -L https://github.com/ohmyzsh/ohmyzsh/tarball/master | tar xz
code_folder=`ls -l | grep ohmyzsh | sed 's/.* //g'` && mv $code_folder ~/.oh-my-zsh
mv -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
popd

yum -y install util-linux-user || true
chsh -s /bin/zsh

### plugin: autosuggestions
git clone https://gitee.com/atamagaii/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

### plugin: syntax highlighting
git clone https://gitee.com/atamagaii/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
echo '''
DISABLE_UPDATE_PROMPT=true

source /etc/profile
''' >> ~/.zshrc

### theme config
#### prompt: show user and hostname
#### https://askubuntu.com/a/483861
sed -i 's/PROMPT=/#PROMPT=/g' ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
echo 'PROMPT="%(!.%{%F{yellow}%}.)%n@%{$fg[white]%}%M %{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}"' >> ~/.oh-my-zsh/themes/robbyrussell.zsh-theme

### match *
echo "setopt nonomatch" >> ~/.zshrc