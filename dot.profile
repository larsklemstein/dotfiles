if [[ $- == *i* ]]  
then
    if [[ $SHELL = */bin/bash && -f ~/.bashrc ]]
    then
        . ~/.bashrc
    fi
fi

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/lklemstein/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
