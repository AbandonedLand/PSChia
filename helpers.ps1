function Get-FileHashFromUrl{
    param(
        [Parameter(Mandatory=$true)]
        $url,
        [Parameter(Mandatory=$true)]
        $tmp_file_path
    )
    
    (New-Object System.Net.WebClient).DownloadFile($url, $tmp_file_path)
    $thisFileHash = Get-FileHash $tmp_file_path
    Remove-Item -Path $tmp_file_path
    return $thisFileHash.Hash
}