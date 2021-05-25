#!/bin/sh

USER_NAME=$1

function AddToSudoers () {
    USER_NAME=$1
    echo "Adding user $USER_NAME to sudoers file"
    echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers;
    shift
}

if [ "$USER_NAME" == "" ]
then
    echo "Provide username when invoking the script"
else
    echo "Create a user and add to sudoers file"
    sudo adduser $USER_NAME
    AddToSudoers $USER_NAME

    echo "copying public keys to ~/.ssh directory..."
    cp ./public_keys "/home/$USER_NAME/.ssh/authorized_keys"
    chmod 600 "/home/$USER_NAME/.ssh/authorized_keys"
    echo "authorized_keys copied"

    echo "copying dotfiles to home directory"
    cp -r ./dotfiles/. "/home/$USER_NAME/."

    echo "installing zsh"
    sudo -u $USER_NAME sudo apt install -y zsh
    sudo -u $USER_NAME zsh --version

    echo "making zsh your default shell"
    sudo -u $USER_NAME sudo chsh -s $(which zsh)

    echo "installing zsh plugins"
    git clone https://github.com/zsh-users/zsh-autosuggestions "/home/$USER_NAME/.oh-my-zsh/plugins/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "/home/$USER_NAME/.oh-my-zsh/plugins/zsh-syntax-highlighting"

    echo "installing oh-my-zsh"
    sudo -u $USER_NAME sudo sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
