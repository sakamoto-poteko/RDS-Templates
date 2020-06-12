$attempt = dsregcmd /join
if ($attempt -like '*Error*') {
    return 1
} else {
    return 0
}
