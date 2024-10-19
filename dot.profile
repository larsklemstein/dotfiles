if [[ $- == *i* ]]  
then
    if [[ $SHELL = */bin/bash && -f ~/.bashrc ]]
    then
        . ~/.bashrc
    fi
fi
