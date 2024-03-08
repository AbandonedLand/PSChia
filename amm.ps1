# App to run the AMM


<#
    Import the Wallet Functions using dot notion ( . ./script.ps1 )
#>
. ./wallet.ps1





# Fill Wallet with XCH

$coins = Invoke-WalletGetSpendableCoins -wallet_id 1
$address = 'xch1gjh6ehqk9m0mvyx4knt3j0zx09nllmech2jeq7cv2lsqgzdh2mnqc5zk2t'


$pairs = @{
    'DBX'='c0952d9c3761302a5545f4c04615a855396b1570be5c61bfd073392466d2a973'
    'SBX'='1a6d4f404766f984d014a3a7cab15021e258025ff50481c73ea7c48927bd28af'
    'HOA'='ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0'
}

$uri = 'https://api.v2.tibetswap.io/quote/ad79860e5020dcdac84336a5805537cbc05f954c44caf105336226351d2902c0?amount_in=100000000000&xch_is_input=true&estimate_fee=false'
Invoke-RestMethod -Uri $uri -Method Get
