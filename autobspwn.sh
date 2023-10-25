#!/bin/bash


echo -ne "Actualizando paquetes \n"

if [[ "$1" ]];then
  user="$1"

  sudo apt install build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev -y
  sudo apt install feh -y
  path="$(pwd)"

  mkdir install
  cd install

  echo  -ne "Clonando Bspwm"
  git clone https://github.com/baskerville/bspwm.git
  echo -ne "Clonand sxhdk"
  git clone https://github.com/baskerville/sxhkd.git

  echo -ne "Compilando Bspwm"
  cd bspwm/
  make
  sudo make install
  echo -ne "Compilando Bspwm"
  cd ../sxhkd/
  make
  sudo make install

  echo -ne "Copiando Archivos de Configuracion de Bspwm y Sxhdk"
  sudo apt install bspwm -y
  cd $path
  mkdir ~/.config/sxhkd
  cp -r $path/bspwm/ ~/.config/bspwm/
  cp $path/sxhkd/sxhkdrc ~/.config/sxhkd/
  chmod +x ~/.config/bspwm/bspwmrc
  cp $path/fondo.png ~/Pictures/fondo.png

  echo -ne "Instalando dependencias"


  # hay una dependencia que da problema hay que sacarla
  sudo apt install cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libnl-genl-3-dev -y
  sudo apt-get install libuv1-dev -y

  echo -ne "Clonando polybar e instalando"
  cd $path/install
  git clone --recursive https://github.com/polybar/polybar
  cd polybar/
  mkdir build
  cd build/
  cmake ..
  make -j$(nproc)
  sudo make install

  echo -ne "Copiando Archivos de Configuracion la polybar"
  cp -r $path/polybar/ ~/.config/

  echo -ne "Instalando dependecias\n"
  sudo apt update
  sudo apt install meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev -y

  echo -ne "Instalando picom\n"
  cd $path/install
  git clone https://github.com/ibhagwan/picom.git
  cd picom/
  git submodule update --init --recursive
  meson --buildtype=release . build
  ninja -C build
  sudo ninja -C build install

  echo -ne "Copiando Archivos de Configuracion para picom\n"
  mkdir ~/.config/picom
  cp $path/picom/* ~/.config/picom/



  echo -ne "Instalando rofi"
  sudo apt install rofi -y
  echo -ne "Copiando Archivos de Configuracion para rofi"
  mkdir -p ~/.config/rofi/themes/
  cp $path/polybar/shapes/scripts/rofi/* ~/.config/rofi/themes/

  #instalar bat , lsd, fzf y ranger
  echo -ne "Instalando bat"
  wget "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb"
  sudo dpkg -i "bat_0.24.0_amd64.deb"
  echo -ne "Instalando lsd"
  wget "https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd_1.0.0_amd64.deb"

  echo -ne "Instalando zstd para crear nuevo .deb"
  sudo apt install zstd -y
  set -e
  ar x "lsd_1.0.0_amd64.deb"
  zstd -d < control.tar.zst | xz > control.tar.xz
  zstd -d < data.tar.zst | xz > data.tar.xz
  ar -m -c -a sdsd "lsd_1.0.0_amd64"_repacked.deb debian-binary control.tar.xz data.tar.xz
  rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst
  sudo dpkg -i "lsd_1.0.0_amd64_repacked.deb"

  sudo -u root chown $user:$user /root
  sudo -u root chown $user:$user /root/.cache -R
  sudo -u root chown $user:$user /root/.local -R


  echo -ne "Instalando Kitty para $user"
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  echo -ne "Instalando kitty para root"
  sudo bash -c "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"


  echo -ne "copiando archivos de configuracion para kitty"
  cp $path/kitty/* ~/.config/kitty/
  sudo ln -sf ~/.config/kitty/kitty.conf /root/.config/kitty/kitty.conf
  sudo ln -sf ~/.config/kitty/current-theme.conf /root/.config/kitty/current-theme.conf

  echo -ne "Instalando zsh"
  sudo bash -c "apt install zsh -y"

  echo -ne "Instalando p10k para $user"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

  echo -ne "Instalando p10k para root"
  sudo bash -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k"
  sudo bash -c "echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc"

  echo -ne "Copiando archivos de configuracion para zsh y p10k"
  if [ -f /root/.zshrc ];then
    sudo rm /root/.zshrc
  fi

  if [ -f /root/.p10k.zsh ];then
    sudo rm /root/.p10k.zsh
  fi
  sudo bash -c "cp $path/zsh/.zshrc /root/.zshrc"
  sudo bash -c "cp $path/zsh/.p10k.zsh /root/.p10k.zsh"
  ln -sf /root/.zshrc ~/.zshrc
  ln -sf /root/.p10k.zsh ~/.p10k.zsh

  pip3 install pywal
  sudo pip3 install pywal
  sudo apt install calc -y
  cd $path/install
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
  sudo bash -c "cd /usr/local/share/fonts/; mv $path/install/Hack.zip . ; unzip Hack.zip; rm Hack.zip;fc-cache -v"

  cd $path/install
  git clone --depth=1 https://github.com/adi1090x/polybar-themes.git
  cd polybar-themes
  chmod +x setup.sh
  ./setup.sh
  rm -rf ~/.config/polybar/shapes/
  cp -r $path/polybar/shapes ~/.config/polybar/
  rm -rf $path/install

  sudo apt install zsh-syntax-highlighting zsh-autosuggestions -y 

  sudo usermod --shell /usr/bin/zsh $user
  sudo usermod --shell /usr/bin/zsh root

  # revisar si el networkmanager_dmenu es necesario
else
  echo "Uso: ./autobspwn.sh {user}"
fi


