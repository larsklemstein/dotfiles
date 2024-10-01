if [ -d $HOME/tmp ]
then
    find $HOME/tmp -mtime +10 -exec /bin/rm -rf {} +
fi

if [[ $- == *i* ]]  
then
    if [[ $SHELL = */bin/bash && -f ~/.bashrc ]]
    then
        . ~/.bashrc
    fi
fi
