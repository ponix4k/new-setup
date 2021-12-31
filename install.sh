
echo "###############################"
echo "## New install Setup scripts ##"
echo "###############################"
echo " "


echo "##################"
echo "## Pulling keys ##"
echo "##################"
echo " "

curl https://github.com/ponix4k.keys > ~/.ssh/authorized_keys 

sudo apt install vim git snapd mono-complete golang nodejs default-jdk npm -y

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

echo "##################################"
echo "#### Create Files and Folders ####"
echo "##################################"
echo " "

mkdir ~/backups
touch ~/.bash_aliases
echo "if [ -e $HOME/.bash_aliases ]; then" >> ~/.bashrc
echo "    source $HOME/.bash_aliases" >> ~/.bashrc
echo "fi" >> ~/.bashrc

echo "##################################"
echo "#### Adding Aliases ####"
echo "##################################"
echo " "

echo "alias _full_update='sudo apt-get update && sudo apt-get upgrade -y && sudo apt full-upgrade'" >> ~/.bash_aliases
echo "alias apt='sudo apt'" >> ~/.bash_aliases
echo "alias c='clear'" >> ~/.bash_aliases
echo "alias df='df -h'" >> ~/.bash_aliases
echo "alias egrep='egrep --color=auto'" >> ~/.bash_aliases
echo "alias fgrep='fgrep --color=auto'" >> ~/.bash_aliases
echo "alias gh='history | grep'" >> ~/.bash_aliases
echo "alias grep='grep --color=auto'" >> ~/.bash_aliases

echo "alias l='ls -CF'" >> ~/.bash_aliases
echo "alias la='ls -A'" >> ~/.bash_aliases
echo "alias ll='ls -latr'" >> ~/.bash_aliases
echo "alias ls='ls --color=auto'" >> ~/.bash_aliases


echo "alias myip='curl ipinfo.io/ip'" >> ~/.bash_aliases
echo "alias rvm-restart='rvm_reload_flag=1 source '~/.rvm/scripts/rvm'\''' " >> ~/.bash_aliases
echo "alias sl='ls'" >> ~/.bash_aliases
echo "alias r!="sudo reboot"" >> ~/.bash_aliases

echo "alias gstat="git status"" >> ~/.bash_aliases
echo "alias glog="git log"" >> ~/.bash_aliases


echo "#####################"
echo "## Install Vundle  ##"
echo "#####################"
echo " "

git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

echo "#####################"
echo "## Install YCM  ##"
echo "#####################"
echo " "

#cd ~/.vim/bundle/YouCompleteMe
#python3 install.py --all

echo "#############################"
echo "#### Setting up ~/.vimrc ####"
echo "#############################"

cp ~/.vimrc ~/backups/vimrc.bak
source ~/.vimrc
