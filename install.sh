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

sudo apt install -y vim git tmux snapd mono-complete golang nodejs default-jdk npm libpq-dev postgresql openssh-server

sudo ufw allow ssh

echo "##################################"
echo "####    Copying mono fonts    ####"
echo "##################################"
echo " "

mkdir -p ~/.local/share/fonts
cp fonts/*.otf ~/.local/share/fonts/
cd $wd

echo "Current dir:" `pwd`
echo "##################################"
echo "#### Create Files and Folders ####"
echo "##################################"
echo " "

mkdir ~/backups
touch ~/.aliases

if [ -n "$BASH_VERSION" ]; then
    echo "You are using Bash version $BASH_VERSION."
    echo "###"
    echo "if [ -e $HOME/.aliases ]; then" >> ~/.bashrc
    echo "    source $HOME/.aliases" >> ~/.bashrc
    echo "fi" >> ~/.bashrc
    echo "### \n"
elif [ -n "$ZSH_VERSION" ]; then
    echo "You are using Zsh version $ZSH_VERSION."
     echo "if [ -e $HOME/.aliases ]; then" >> ~/.zshrc
    echo "    source $HOME/.aliases" >> ~/.zshrc
    echo "fi" >> ~/.zshrc
else
    echo "Unknown shell."
fi

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
cat $wd/configs/vimrc.txt > ~/.vimrc
cat $wd/configs/bash_aliases.txt > ~/.aliases
cat ~/.aliases
source ~/.vimrc
vim +PluginInstall +qall

