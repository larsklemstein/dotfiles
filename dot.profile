if [[ $- == *i* ]]  
then
    if [[ $SHELL = */bin/bash && -f ~/.bashrc ]]
    then
		echo $PATH >/tmp/pp
        . ~/.bashrc
    fi
fi
