#! /bin/bash
wd=(`pwd`)

echo "current directory: " $wd
echo "###############################"
echo "## New install Setup scripts ##"
echo "###############################"
echo " "

echo "##################"
echo "## Pulling keys ##"
echo "##################"
echo " "

read -p "Enter Github Username: " username
touch ~/.ssh/authorized_keys
curl https://github.com/$username.keys > ~/.ssh/authorized_keys

echo "########################"
echo "### Create Cron Task ###"
echo "########################"
echo " "


read -p "Enter new Hostname: " hostname
sudo hostnamectl set-hostname $hostname

crontab -l > crontab.txt
echo "### Crontask for Key Puller  ###" >> crontab.txt
echo "* * * * * curl https://github.com/$username.keys > ~/.ssh/authorized_keys" >> crontab.txt
crontab `pwd`/crontab.txt
rm `pwd`/crontab.txt


sudo apt install -y vim git tmux snapd mono-complete golang nodejs default-jdk npm libpq-dev postgresql

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf
cd $wd

echo "Current dir:" `pwd`
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
echo "#### Adding Git Branch Status ####"
echo "##################################"
echo " "


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
cat $wd/vimrc.txt > ~/.vimrc
cat $wd/bash_aliases.txt > ~/.bash_aliases
cat ~/.bash_aliases
source ~/.vimrc
vim +PluginInstall +qall

