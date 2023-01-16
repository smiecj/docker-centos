#!/bin/bash

source /etc/profile
rm -rf /root/.oh-my-zsh
yum -y install zsh git

## online install
# zsh_install_tmp_script=/tmp/install.sh
# echo "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)" > $zsh_install_tmp_script

# sed -i "s/REPO=.*/REPO=\${REPO:-ohmyzsh\/ohmyzsh}/g" $zsh_install_tmp_script
# sed -i "s/REMOTE=.*/REMOTE=\${REMOTE:-https:\/\/gitee.com\/\${REPO}.git}/g" $zsh_install_tmp_script
# echo Y | sh $zsh_install_tmp_script
# rm -f $zsh_install_tmp_script

## offline install
pushd /tmp
# curl -L https://github.com/ohmyzsh/ohmyzsh/tarball/master | tar xz
# code_folder=`ls -l | grep ohmyzsh | sed 's/.* //g'` && mv $code_folder ~/.oh-my-zsh
git clone https://github.com/ohmyzsh/ohmyzsh && mv ohmyzsh ~/.oh-my-zsh
mv -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
popd

yum -y install util-linux-user || true
chsh -s /bin/zsh

### plugin: autosuggestions
git clone https://gitee.com/atamagaii/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

### plugin: syntax highlighting
git clone https://gitee.com/atamagaii/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

### don't auto update
#### https://stackoverflow.com/questions/11378607/oh-my-zsh-disable-would-you-like-to-check-for-updates-prompt
sed -i '1s/^/DISABLE_AUTO_UPDATE=true\nDISABLE_UPDATE_PROMPT=true\n/' ~/.zshrc

### theme config
#### prompt: show user and hostname
#### https://askubuntu.com/a/483861
sed -i 's/PROMPT=/#PROMPT=/g' ~/.oh-my-zsh/themes/robbyrussell.zsh-theme
echo 'PROMPT="%(!.%{%F{yellow}%}.)%n@%{$fg[white]%}%M %{$fg_bold[red]%}➜ %{$fg_bold[green]%}%p %{$fg[cyan]%}%c %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%} % %{$reset_color%}"' >> ~/.oh-my-zsh/themes/robbyrussell.zsh-theme

### match *
echo "setopt nonomatch" >> ~/.zshrc

### not share history between session
echo "unsetopt share_history" >> ~/.zshrc

### don't notice when remove multiple files
#### https://stackoverflow.com/a/27995504
echo "setopt RM_STAR_SILENT" >> ~/.zshrc

### source profile
echo "source /etc/profile" >> ~/.zshrc

### set zsh ignore git status to avoid too slow
#### https://stackoverflow.com/a/25864063
git config --global --add oh-my-zsh.hide-status 1
git config --global --add oh-my-zsh.hide-dirty 1