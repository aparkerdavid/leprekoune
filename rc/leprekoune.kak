declare-option range-specs leprekoune

face global leprekoune0 blue
face global leprekoune1 green
face global leprekoune2 magenta
face global leprekoune3 bright-yellow
face global leprekoune4 cyan

define-command leprekoune %{

    # Leprekoune works by creating a detached shell that will await input from a fifo
    # The input will consist of the verbatim contents of the buffer to be highlighted
    # Once the input arrives, the detached shell will compose the appropriate highlighting command,
    # and send it back to Kakoune.
    evaluate-commands nop %sh{ {
        # This comment allows use of the following environment variables:
        # $kak_client $kak_timestamp
        cat $kak_config/plugins/leprekoune/.leprekoune-fifo \
          | $kak_config/plugins/leprekoune/leprekoune-helper \
          | kak -p ${kak_session}
    } > /dev/null 2>&1 < /dev/null & }

    # write the buffer to the fifo
    execute-keys -draft '%$cat - > $kak_config/plugins/leprekoune/.leprekoune-fifo<ret>'
}

define-command leprekoune-enable %{
    evaluate-commands %sh{
        mkfifo $kak_config/plugins/leprekoune/.leprekoune-fifo
    }
    hook -group leprekoune window InsertIdle .* %{ leprekoune }
    hook -group leprekoune window NormalIdle .* %{ leprekoune }
    add-highlighter window/ ranges leprekoune
}

define-command leprekoune-disable %{
    evaluate-commands %sh{
        rm $kak_config/plugins/leprekoune/.leprekoune-fifo
    }
    remove-highlighter window/ranges_leprekoune
    remove-hooks window leprekoune
}
