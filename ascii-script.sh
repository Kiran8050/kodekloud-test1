#!/bin/bash
sudo apt-get install cowsay -y
cowsay -f dragon "This is dragon" >> dragon.txt
grep -i "dragon" dragon.txt
cat dragon.txt
ls -ltra