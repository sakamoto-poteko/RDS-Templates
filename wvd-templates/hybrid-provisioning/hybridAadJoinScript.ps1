$value = dsregcmd /join
if ($value -like "*Error*")
{
    return 1
} else
{
    return 0
}