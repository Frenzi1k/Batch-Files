[string]$confirm = ""
function readLine {
    $script:confirm = Read-Host
}

function error {
    Write-Host 'You must type "yes" or "no"!'
}

function exitNow{
    pause
    exit
}

while (1){
    Write-Host "Format disk? [yes/no]"
    readLine
    switch($confirm){
        "yes"{
            Write-Host "Are you sure about this? [yes/no]"
            readLine
            switch ($confirm){
                "yes"{
                    Write-Host "Done. You're looking at a blue screen now"
                    exitNow
                }
                "no"{
                    Write-Host "I've done nothing. See you next time"
                    exitNow
                }
                default{
                    error
                }
            }
        }
        "no" {exit}
        default {error}
    }
}


