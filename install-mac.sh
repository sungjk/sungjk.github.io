#!/bin/sh
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install rbenv ruby-build
echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.zshrc
source ~/.zshrc
rbenv install 3.0.0
rbenv global 3.0.0
ruby -v
rbenv rehash
gem install github-pages
gem install pygments.rb
gem install webrick
echo "You can run the server by using 'jekyll serve'."
