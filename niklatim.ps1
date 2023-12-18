# v0.1 By Itamar Rosenblum

# title
$host.UI.RawUI.WindowTitle = "Niklatim System v0.1 - by Itamar Rosenblum"

# opening screen
write-host "> Welcome to Niklatim System v0.1 - by Itamar Rosenblum"
write-host " "
write-host "> Please note!"
write-host " "
write-host "(!) First enter the users to be modified in the users_list.txt"
write-host " "
write-host "(!) Then please enter an example user"
write-host " "
# prompt to continue execution of code
Read-Host -Prompt "> Press ""Enter"" to continue or ""CTRL+C"" to quit" | Out-Null

# input box for example user
Add-Type -AssemblyName Microsoft.VisualBasic
$title = "Niklatim System - by Itamar Rosenblum"
$msg = "Enter an example user:"
$user_input = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
$example_user = Get-ADUser -Identity $user_input
# getting users to be modified from txt file
$users = Get-Content U:\Itamar\Code\niklatim\users_list.txt

if ($example_user) {
    # confirmation box
    Add-Type -AssemblyName PresentationFramework
    $confirm = [System.Windows.MessageBox]::Show("Do you want to transfer permisions from: ""$($user_input)""", "Confirmation", "YesNo")

    if (($confirm -eq "Yes")) {
        #$example_user = Get-ADUser -Identity #example_user_here
        ForEach ($user in $users) {
            # enable user
            Enable-ADAccount -Identity $user
            write-host "> User $($user) has been enabled"

            # remove from group
            $userInfo = Get-ADUser -Identity $user -properties MemberOf
            Foreach ($group in $userInfo.MemberOf) { Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false }

            # add to group
            Get-ADUser -Identity $example_user -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $user
            write-host "> User $($user) has been added to new groups"

            # get target OU
            $new_ou = (($example_user).DistinguishedName -split '(?<!\\),', 2)[-1]
            # get user object
            $old_ou = Get-ADUser -Identity $user
            # change OLD OU to NEW OU
            $old_ou | Move-ADObject -TargetPath $new_ou
            write-host "> User $($user) OU has been changed"
            write-host "- - - - - - - - - - - - - - - - -"
        } 
    }   elseif ($confirm -eq "No") {
            cls
            Write-Host "> You canceled the operation"
            write-host " "
            # prompt to end execution of code
            Read-Host -Prompt "> Press ""CTRL+C"" to quit"
        }
}   elseif ($null -eq $example_user) {
    cls
    Write-Host "> User ""$($user_input)"" not found"
    write-host " "
    # prompt to end execution of code
    Read-Host -Prompt "> Press ""CTRL+C"" to quit"
}