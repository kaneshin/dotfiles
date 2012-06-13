# Make sure that {{_input_:command name}} exists
{{_input_:command name}}=`which {{_input_:command name}} 2>&1`
if [[ $? != 0 ]]; then
    echo "There is no {{_input_:command name}} on this computer."
    echo "Install {{_input_:command name}} first, and then try again."
    exit $?
fi
