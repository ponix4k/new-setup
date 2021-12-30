
echo "###############################"
echo "## New install Setup scripts ##"
echo "###############################"
echo " "

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
cat aliases.txt >> ~/.bash_aliases


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
cat vimrc.bak > ~/.vimrc
source ~/.vimrc
