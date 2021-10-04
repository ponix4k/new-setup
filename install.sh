
echo "#######################"
echo "## Install software  ##"
echo "#######################"

apt install vim -y

echo "#############################"
echo "# Adding Regolith Settings  #"
echo "#############################"

cp ~/.config/regolith/Xresources cp ~/.config/regolith/Xresources.bak

echo "i3-wm.gaps.inner.size: 10" >> ~/.config/regolith/Xresources
echo "gnome.terminal.use-transparent-background: true" >> ~/.config/regolith/Xresources
echo "gnome.terminal.background-transparency-percent: 15" >> ~/.config/regolith/Xresources

echo "#############################"
echo "#### Setting up ~/.vimrc ####"
echo "#############################"

cp ~/.vimrc ~/backups/vimrc.bak
cat vimrc.bak > ~/.vimrc
source ~/.vimrc

